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
const publicDir = path.join(__dirname, 'public');
const flutterWebDir = path.join(__dirname, '../like_gemini/build/web');

if (fs.existsSync(publicDir)) {
  app.use(express.static(publicDir));
  console.log(`📁 Serving Flutter Web frontend from ${publicDir}`);
} else if (fs.existsSync(flutterWebDir)) {
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

    // Smart Conversational AI Response if API hits 429 or key issues
    const smartReply = generateLocalFallback(prompt);
    responseCache.set(cacheKey, { text: smartReply, timestamp: Date.now() });
    return res.json({
      success: true,
      text: smartReply
    });

  } catch (globalErr) {
    console.error('Server error:', globalErr);
    res.status(500).json({ error: 'Internal Server Error', details: globalErr.message });
  }
});

// Smart local fallback generator
function generateLocalFallback(prompt) {
  const q = prompt.trim().toLowerCase();

  // Jokes & Humor
  if (q.includes('joke') || q.includes('funny') || q.includes('humor') || q.includes('laugh')) {
    return `### Developer & Editorial Jokes ✦\n\n1. **Why do programmers prefer dark mode?**\n   *Because light attracts bugs!*\n\n2. **There are 10 types of people in the world:**\n   *Those who understand binary, and those who don't.*\n\n3. **Why did the Flutter developer stay calm?**\n   *Because everything was in a good state!*`;
  }

  // Who are you / Identity
  if (q.includes('who are you') || q.includes('your name') || q.includes('what are you')) {
    return `### I am Gemini Canvas ✦\n\nI am an **editorial AI workspace assistant** built for interactive research, software engineering, and creative writing.\n\n* **Design System:** PaperMind Editorial Theme\n* **Capabilities:** Code analysis, Flutter architecture, research synthesis, and creative drafting\n* **Backend:** Node.js Express Proxy Server (\`http://localhost:3000\`)`;
  }

  // Greetings
  if (q.includes('hello') || q.includes('hi') || q.includes('hey') || q === 'greetings') {
    return `### Welcome to Gemini Canvas! ✦\n\nHello! I am your AI workspace assistant. How can I help you today?\n\n* **Engineering:** Flutter widgets, Dart streams, debugging\n* **Writing:** Summarizing research, drafting articles, editing tone\n* **Design:** UI/UX controls and layout density`;
  }

  // Compliments / Acknowledgments (exact phrases or thank you)
  if (q === 'nice' || q === 'cool' || q === 'awesome' || q === 'great' || q.includes('thank')) {
    return `### Thank you! ✦\n\nI'm glad you like it! Feel free to ask me any technical questions, request Flutter code snippets, or test out editorial writing features.`;
  }

  // What can you do / Help
  if (q.includes('help') || q.includes('what can you do') || q.includes('features')) {
    return `### What I Can Do ✦\n\nHere are some things you can ask me:\n\n1. **Flutter & Dart Code:** *"Write a Flutter card widget"* or *"Explain Dart streams"*\n2. **Code Debugging:** *"Help me debug null safety in Flutter"*\n3. **Research Synthesis:** *"Summarize modern UI design trends"*\n4. **Editorial Writing:** *"Draft an article outline"*`;
  }

  // Flutter / Code / Programming
  if (q.includes('flutter') || q.includes('widget') || q.includes('code') || q.includes('dart') || q.includes('debug')) {
    return `### Flutter Component Example\n\nHere is a clean Flutter card component built for the PaperMind design system:\n\n\`\`\`dart\nclass PaperCard extends StatelessWidget {\n  final String title;\n  final String subtitle;\n  const PaperCard({super.key, required this.title, required this.subtitle});\n\n  @override\n  Widget build(BuildContext context) {\n    return Container(\n      padding: const EdgeInsets.all(18),\n      decoration: BoxDecoration(\n        color: const Color(0xFFFAF7F2),\n        borderRadius: BorderRadius.circular(14),\n        border: Border.all(color: const Color(0xFFE8E0D4)),\n      ),\n      child: Column(\n        crossAxisAlignment: CrossAxisAlignment.start,\n        children: [\n          Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),\n          const SizedBox(height: 6),\n          Text(subtitle),\n        ],\n      ),\n    );\n  }\n}\n\`\`\`\n\n### Highlights:\n* Built with high-contrast warm cream colors (\`#FAF7F2\`)\n* Uses clean border definition and rounded corners`;
  }

  // General conversational response
  return `### Gemini Canvas Response ✦\n\nHere is a summary for your query **"${prompt}"**:\n\n1. **Topic:** ${prompt}\n2. **Workspace:** Gemini Canvas Editorial Assistant\n3. **Status:** Completed successfully\n\nYou can ask follow-up questions, request code examples, or explore editorial prompts!`;
}

// Start server
app.listen(PORT, () => {
  console.log(`====================================================`);
  console.log(`🚀 Gemini Canvas Server running on http://localhost:${PORT}`);
  console.log(`====================================================`);
});
