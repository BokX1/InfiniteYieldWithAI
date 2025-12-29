# SmartInfiniteYield (SIY) V1.0 Stable

> **Original Idea by VolQ5** | Powered by Pollinations.AI (Gemini Model)

**SmartInfiniteYield** is an open-source, next-generation wrapper for the popular Roblox admin script Infinite Yield. It integrates a Large Language Model (LLM) to translate natural language into executable admin commands, creating a seamless "Assistant" experience.

It also features a chat mode that knows what game you’re playing and your username, giving it context and knowledge to act as an assistant for the game.

Instead of memorizing syntax like ;ws 50 or ;esp, simply type "Make me fast" or "Show me where everyone is."

- Current Version **1.0 Stable**. More features is coming!

---

## ⚡ Key Features

* **🧠 Natural Language Processing:** Powered by the **Gemini/Grok** model via Pollinations.AI, SIY understands context, slang, and vague requests.
* **🌉 The "Bridge" Architecture:** Uses a custom Source Injection method to hook directly into Infinite Yield's internal `execCmd` function. This ensures 100% execution reliability without relying on chat simulation or unstable GUI searching.
* **📱 Modern UI (V1.0):**
* **Glassmorphism Design:** Sleek dark mode with interactive hover states.
* **Mobile-First:** Fully draggable and touch-friendly on all devices.
* **Visual Feedback:** Input box glows green and locks during "Thinking" states to prevent spam.
* **Floating Icon:** Minimizes to a subtle brain-chip icon to save screen space.


* **☯️ Dual Modes:**
* **CMD Mode (Orange):** Translates text directly into Infinite Yield commands.
* **CHAT Mode (Blue):** Acts as a Game Assistant. Ask questions like *"How do I play this game?"* and receive advice via IY Notifications.


* **🌍 Context Awareness:** Automatically detects the **Game Name** and your **Username** to provide game-specific advice in Chat Mode.

---

## 🚀 Installation

### Prerequisites

* A Roblox Executor that supports `request` or `http_request` (e.g., Synapse Z, Solara, Krampus, Fluxus, etc.).
* *Note: Standard Roblox Studio cannot run this script due to HTTP header restrictions.*

### The Script

Copy the source code below or load it directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()

```

---

## 📖 Usage Guide

### 1. The Interface

Upon execution, you will see the **Smart Bar** at the top of the screen.

* **Input Box:** Type your request here and press Enter.
* **Mode Button:** Toggles between **CMD** and **CHAT**.
* **Minimize (-):** Shrinks the UI to a floating icon.

### 2. CMD Mode (Orange)

**Goal:** Execute commands.

* *User:* "Fly me and make me invisible."
* *AI:* Executes `;fly` and `;invisible`.
* *User:* "Kill the guy next to me."
* *AI:* Executes `;kill [PlayerName]`.

### 3. CHAT Mode (Blue)

**Goal:** Get information/strategy.

* *User:* "Where is the safe spot in this game?"
* *AI:* (Notification) "Check the top of the tower, usually safe from zombies."
* *User:* "What does ;noclip do?"
* *AI:* (Notification) "It allows you to walk through walls."

---

## ⚙️ Configuration

You can modify the `CONFIG` table at the top of the script to customize your experience:

```lua
local CONFIG = {
    -- Your Pollinations.AI API Key (Required for high-speed requests)
    ApiKey = "your_key", 
    
    -- API Endpoint (OpenAI Standard)
    Endpoint = "https://gen.pollinations.ai/v1/chat/completions",
    
    -- Model Selection
    Model = "gemini", -- Options: 'gemini', 'gemini-fast', 'openai', 'grok'
}

```

---

## 🏗 Architecture

**SmartInfiniteYield** solves the "Sandboxing" problem of Roblox scripts using a specific load order:

1. **Check:** Looks for an existing Infinite Yield instance.
2. **Fetch:** If missing, it fetches the raw Infinite Yield source code.
3. **Inject:** It appends a custom "Bridge Function" to the source code before running it:
```lua
getgenv().PseudoBridge = { Exec = function(cmd) if execCmd then execCmd(cmd) end end }

```


4. **Execute:** It runs the modified IY, exposing `execCmd` to the global environment securely.
5. **Connect:** The AI interface connects to `PseudoBridge` to send commands directly to the engine.

---

## ⚖️ License

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

---

## 📝 Credits

* **Original Idea & Concept:** VolQ5
* **AI Integration:** Gemini (Google) via Pollinations.AI
* **Backend:** Infinite Yield (EdgeIY)
