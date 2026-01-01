# SmartInfiniteYield (SIY) - V1.2 Stable

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

**SmartInfiniteYield** is an open-source, next-generation wrapper for the popular Roblox admin script, [Infinite Yield](https://github.com/EdgeIY/infiniteyield). Unlike standard wrappers, SIY implements a **Self-Correcting Logic Engine** that translates natural language into precise execution strings.

It features a **Recursive Feedback Loop**: if the AI targets a non-existent player or generates invalid syntax, the script detects the error, injects the correct server context, and forces the AI to fix its own mistake before executing.

The API is protected by CloudFlare to prevent bad actor (abuse)

### ⚡ Key Features

**🔍 Predictive Command Search (New)**
* **Google-Style Dropdown:** As you type, a smart menu appears below the input box suggesting commands.
* **Priority Ranking:** The system knows which commands are most important. Typing "fl" suggests `;fly` (High Priority) before `;flyspeed` (Low Priority).
* **Type Hinting:** Suggestions explicitly show required arguments (e.g., `speed [num]`, `goto [player]`).

**⌨️ Smart Keybinds (New)**
* **Intelligent Toggles:** Bind a command once, and the script handles the rest. Binding 'F' to `fly` automatically cycles between `;fly` and `;unfly` on each press.
* **Master Toggle:** Press **Right Shift** to instantly hide or show the interface.

**🚀 Hybrid Execution Engine**
* **Zero-Latency "Fast Path":** We have integrated the **entire** Infinite Yield command dictionary (200+ commands). Standard commands execute locally with **0ms latency**, bypassing the AI entirely.
* **Context-Aware Fallback:**
    1. **Check Local:** Is it a known command? → Execute immediately.
    2. **Check Context:** Is it complex natural language? → Send to AI.
    3. **Validate:** Does the target exist? → Verify before execution.

**📱 Adaptive Interface**
* **Responsive Scaling:** The GUI detects the device type and adjusts dynamically (Fixed 500px on PC, 80% Width on Mobile).
* **Smart Status Bar:** A transparent feedback loop shows exactly what the engine is doing (`[FAST]`, `[AI]`, `[ERROR]`).

---

### 📜 Changelog

Here is the final, consolidated changelog for **Smart Infinite Yield v1.2**, combining your new UI/Logic updates with the backend optimizations we implemented.

---

### **Version 1.2 Stable**

### **🚀 Core Architecture**

* **Split-Context Strategy:** Separated system prompt into **Static** (Documentation) and **Dynamic** (Context) layers, reducing recurring request costs by **~90%**.
* **Model Migration:** Switched default model from `grok` to `openai` (GPT-5 Mini) for superior caching discounts and logical reasoning.

### **☁️ Cloudflare Worker (Backend)**

* 
**Abuse Gate Expansion:** Raised `MAX_BODY_CHARS` (100k) and `MAX_CACHED_CHARS` (40k) to support large cached system prompts without triggering spam filters.

* 
**Smart Defaults:** Logic now auto-defaults to `openai` if the client does not specify a model.

### **🎮 Logic Engine & Lua Client**

* **Smart Toggles:** Implemented a cycle system for keybinds (e.g., `bind f fly` automatically handles `unfly`).
* **Complete Dictionary:** Expanded local `FastMap` to cover 100% of Infinite Yield commands for maximum local speed before querying AI.
* **Dynamic Tone Mirroring:** Chat Mode now analyzes and mirrors user tone (slang vs. formal) using context injection.
* **Strict Execution Mode:** Enforced temperature `0.1` and negative constraints in CMD Mode to prevent hallucinations and conversational filler.
* **System Override:** Implemented `[SYSTEM OVERRIDE]` tags to forcibly switch the AI from "Translator" to "Assistant" persona in Chat Mode.

### **🖥️ User Interface**

* **Predictive Dropdown:** Replaced "Ghost Text" with a clickable suggestion menu sorted by command popularity.
* **Visual Polish:** Fixed Z-Index layering issues; the status bar now auto-hides when searching to prevent visual clutter.
* **Master Control:** Added **Right Shift** as the universal toggle key for the UI.

### **🐛 Bug Fixes**

* **Identity Hallucination:** Hardcoded "WhoAmI" logic (`User.Name`, `GameName`) into the system prompt to prevent the AI from executing identity questions as commands.
* **Worker Blocks:** Resolved 429 errors caused by the new larger prompt size triggering old length-based abuse filters.

#### **Version 1.1 Final**
* **Hybrid Model:** Introduced the `FastMap` architecture.
* **Mobile Support:** Fixed GUI scaling and "ghost dragging" on touch devices.
* **Status Bar:** Added real-time feedback indicators.

#### **Version 1.0**
* Initial release with basic AI translation.
* Introduced Glassmorphism UI and Dual Mode (CMD/CHAT).

---

### 🚀 Installation

**Prerequisites**

* A Roblox Executor that supports `request`, `http_request`, or `fluxus.request`.
* *Note: Standard Roblox Studio cannot run this script due to HTTP header restrictions.*

**The Script**
Copy the source code below or load it directly:

```lua
loadstring(game:HttpGet("https://raw.githubusercontent.com/BokX1/InfiniteYieldWithAI/refs/heads/main/InfiniteYieldWithAI.Lua"))()

```

---

### 📖 Usage Guide

#### 1. The Interface

* **Input Box:** Type your request here.
* **Mode Button:** Toggles between **CMD** (Execution) and **CHAT** (Advice).
* **Minimize (-):** Shrinks the UI to the floating icon.

#### 2. CMD Mode (Orange)

*Goal: Precise Execution with Auto-Targeting.*

* **User:** "Fling that bacon hair guy."
* **SIY Logic:**
1. Scans players. Finds "BaconHairUser_99".
2. Generates `;fling BaconHairUser_99`.
3. Executes.


* **User:** "Fly at speed 50."
* **SIY Logic:** Matches `[MOVEMENT]` knowledge base -> `;fly 50`.

#### 3. CHAT Mode (Blue)

*Goal: Strategy & Information.*

* **User:** "Where is the safe spot?"
* **SIY Logic:** Detects game is "Tower of Hell" -> Returns: *"Stay on the center platforms to avoid the rotating lasers."*

---

### ⚙️ Configuration

You can modify the `CONFIG` table at the top of the script to customize your experience:

```lua
local CONFIG = {
    -- Your Pollinations.AI API Key
    ApiKey = "your_key", 
    
    -- AI Model (Grok is recommended for logic, Gemini for speed)
    Model = "grok", 
    
    -- Cybernetic Loop Settings
    MaxRetries = 2, -- How many times the AI tries to fix itself before giving up
}

```

---

### 🏗 Architecture

**SmartInfiniteYield V1.2** introduces a **Hybrid Dual-Path Engine** that combines the speed of a traditional admin script with the intelligence of an LLM.

**1. The Logic Flow:**
Every time you type, the engine performs a "First-Principles" check:

* **Path A: The "Fast Path" (Local Execution)**
* **Input:** User types `fly` or `speed 50`.
* **Logic:** The script checks its internal **FastMap Dictionary** (containing 200+ regex patterns).
* **Result:** It finds a match and executes instantly (**0ms Latency**). No API calls are made.


* **Path B: The "Neuro-Symbolic Bridge" (AI Execution)**
* **Input:** User types *"kill the guy in red"*.
* **Logic:** No local match found. The script captures the **Server State** (Player List: `[VolQ5, Guest_99]`) and sends it to the AI.
* **Inference:** The AI analyzes the natural language and the player list.
* **Result:** AI returns `;kill VolQ5`.



**2. The Validation-Retry Loop (Anti-Hallucination):**
If the AI path is triggered, we apply a strict safety layer to prevent errors:

1. **Validation:** The AI suggests `;goto Volcano`.
2. **Check:** Script scans the workspace. Is there a player named "Volcano"? **NO.**
3. **Recursion:**
* Script intercepts the command.
* Sends feedback to AI: `[ERROR: Target 'Volcano' not found. Did you mean 'VolQ5'?]`
* AI Retries: Returns `;goto VolQ5`.


4. **Execution:** Valid command runs.

---

### ⚖️ License

Licensed under the **Apache License, Version 2.0** (the "License"); you may not use this file except in compliance with the License. You may obtain a copy of the License at:

[http://www.apache.org/licenses/LICENSE-2.0](http://www.apache.org/licenses/LICENSE-2.0)

Unless required by applicable law or agreed to in writing, software distributed under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied. See the License for the specific language governing permissions and limitations under the License.

---

### 📝 Credits

* **Original Idea & Concept:** VolQ5
* **AI Integration:** Pollinations.AI (Grok/Gemini)
* **Backend:** Infinite Yield (EdgeIY)
