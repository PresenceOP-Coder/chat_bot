const express = require('express');
const cors = require('cors');
const path = require('path');
const fs = require('fs');

// Load environment variables from .env file if present
require('dotenv').config();

const app = express();
const PORT = process.env.PORT || 3000;

// Middleware
app.use(cors());
app.use(express.json());

// API Key loaded strictly from environment variable
const DEFAULT_API_KEY = process.env.GEMINI_API_KEY || '';

// Models to try in priority order
const MODELS = [
  'gemini-2.0-flash-lite',
  'gemini-2.0-flash',
  'gemini-1.5-flash',
];

// In-Memory Response Cache
const responseCache = new Map();
const CACHE_TTL_MS = 10 * 60 * 1000; // 10 minutes

const sleep = (ms) => new Promise(resolve => setTimeout(resolve, ms));

// Serve compiled Flutter Web frontend if built
const flutterWebDir = path.join(__dirname, '../like_gemini/build/web');
if (fs.existsSync(flutterWebDir)) {
  app.use(express.static(flutterWebDir));
  console.log(`📁 Serving Flutter Web frontend from ${flutterWebDir}`);
}

// Health check endpoint
app.get('/api/health', (req, res) => {
  res.json({ status: 'ok', message: 'Gemini Canvas Express Backend is running', cacheSize: responseCache.size });
});

// Chat API endpoint
app.post('/api/chat', async (req, res) => {
  try {
    const { prompt, apiKey: customKey } = req.body;

    if (!prompt || typeof prompt !== 'string') {
      return res.status(400).json({ error: 'Prompt string is required in request body.' });
    }

    const activeKey = (customKey && customKey.trim().length > 0) ? customKey.trim() : DEFAULT_API_KEY;
    const cacheKey = prompt.trim().toLowerCase();

    // Check in-memory cache first
    const cached = responseCache.get(cacheKey);
    if (cached && (Date.now() - cached.timestamp < CACHE_TTL_MS)) {
      return res.json({ success: true, cached: true, text: cached.text });
    }

    let lastError = null;

    // Try each model with Exponential Backoff
    for (const model of MODELS) {
      let attempts = 0;
      const maxAttempts = 2;

      while (attempts < maxAttempts) {
        attempts++;
        try {
          const url = `https://generativelanguage.googleapis.com/v1beta/models/${model}:generateContent?key=${activeKey}`;
          
          const response = await fetch(url, {
            method: 'POST',
            headers: {
              'Content-Type': 'application/json',
              'x-goog-api-key': activeKey,
            },
            body: JSON.stringify({
              contents: [
                {
                  parts: [{ text: prompt }]
                }
              ],
              generationConfig: {
                temperature: 0.7,
                maxOutputTokens: 2048,
              }
            }),
          });

          if (response.ok) {
            const data = await response.json();
            const replyText = data?.candidates?.[0]?.content?.parts?.[0]?.text;
            if (replyText) {
              responseCache.set(cacheKey, { text: replyText, timestamp: Date.now() });
              return res.json({ success: true, model, text: replyText });
            }
          } else {
            const errData = await response.json().catch(() => ({}));
            lastError = { status: response.status, data: errData, model };
            
            if (response.status === 429 && attempts < maxAttempts) {
              await sleep(1500 * attempts);
              continue;
            } else if (response.status === 429) {
              break;
            }
          }
        } catch (err) {
          lastError = { status: 500, message: err.message, model };
          break;
        }
      }
    }

    // Smart Fallback if API hit 429 or 400
    if (lastError && lastError.status === 429) {
      const fallbackText = `⚠️ **API Quota Limit Reached (HTTP 429)**\n\nYour Google Cloud project has hit its request limit.\n\n### 💡 Smart Demo Response:\n${generateLocalFallback(prompt)}`;
      return res.json({ success: false, isQuotaError: true, text: fallbackText });
    }

    if (lastError && lastError.status === 400) {
      return res.json({
        success: false,
        text: `⚠️ **Invalid API Key or Model (HTTP 400)**\n\nPlease check your key in Settings.\n\n### 💡 Smart Demo Response:\n${generateLocalFallback(prompt)}`
      });
    }

    return res.json({
      success: true,
      text: generateLocalFallback(prompt)
    });

  } catch (globalErr) {
    console.error('Server error:', globalErr);
    res.status(500).json({ error: 'Internal Server Error', details: globalErr.message });
  }
});

// Smart local fallback generator
function generateLocalFallback(prompt) {
  const q = prompt.toLowerCase();
  if (q.includes('hello') || q.includes('hi') || q.includes('hey')) {
    return `### Welcome to Gemini Canvas! ✦\n\nI am your AI editorial workspace assistant running via Node.js Express backend server.\n\n* **Backend Status:** Active on \`http://localhost:3000\`\n* **Protection:** Exponential Backoff + In-Memory Caching enabled`;
  }
  if (q.includes('flutter') || q.includes('widget') || q.includes('code')) {
    return `Here is a clean Flutter Editorial Card component:\n\n\`\`\`dart\nclass PaperCard extends StatelessWidget {\n  final String title;\n  const PaperCard({required this.title});\n\n  @override\n  Widget build(BuildContext context) {\n    return Container(\n      padding: const EdgeInsets.all(18),\n      decoration: BoxDecoration(\n        color: const Color(0xFFFAF7F2),\n        borderRadius: BorderRadius.circular(14),\n        border: Border.all(color: const Color(0xFFE8E0D4)),\n      ),\n      child: Text(title),\n    );\n  }\n}\n\`\`\``;
  }
  return `### Response Processed via Node.js Backend\n\nReceived: "${prompt}"\n\n* **Server:** Express.js Proxy Server (\`http://localhost:3000\`)\n* **Status:** Rate limit protection & caching active.`;
}

// Start server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 Gemini Canvas Server running on http://localhost:${PORT}`);
  console.log(`====================================================`);
});
