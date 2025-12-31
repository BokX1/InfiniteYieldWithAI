# SmartInfiniteYield (SIY) - V1.1 Final

**Original Idea by [VolQ5](https://github.com/BokX1/RbxLuauLLM) | Powered by Pollinations.AI (LLM Model)**

**SmartInfiniteYield** is an open-source, next-generation wrapper for the popular Roblox admin script, [Infinite Yield](https://github.com/EdgeIY/infiniteyield). Unlike standard wrappers, SIY implements a **Self-Correcting Logic Engine** that translates natural language into precise execution strings.

It features a **Recursive Feedback Loop**: if the AI targets a non-existent player or generates invalid syntax, the script detects the error, injects the correct server context, and forces the AI to fix its own mistake before executing.

The API is protected by CloudFlare to prevent bad actor (abuse)

### ⚡ Key Features

**🚀 Hybrid Execution Engine (New)**

* **Zero-Latency "Fast Path":** Implemented a local RegEx-based dictionary (`FastMap`) that instantly recognizes standard Infinite Yield syntax. Commands like `;fly`, `;speed 100`, or `;esp` execute locally with **0ms latency**, bypassing the API entirely.
* **Context-Aware Fallback:** The script employs a smart logic flow:
1. **Check Local:** Is it a known command? → Execute immediately.
2. **Check Context:** Is it complex natural language? → Send to AI.
3. **Validate:** Does the target exist? → Verify before execution.



**📱 Adaptive Interface (New)**

* **Responsive Scaling:** The GUI detects the device type and adjusts its viewport width dynamically:
* **PC:** Fixed 500px width for standard ergonomics.
* **Mobile:** 80% relative screen width to prevent edge-clipping while maintaining reachability.


* **Universal Drag System:** A rewritten input-agnostic drag system that supports `Touch`, `MouseButton1`, and `MouseMovement`, fixing "ghost dragging" issues on mobile devices.

**📊 Smart Status Bar**

* **Transparent Feedback Loop:** A dedicated status bar provides real-time insight into the logic engine's decision-making process:
* <span style="color:#40e682">**[FAST]**</span>: Local execution (Regex Match).
* <span style="color:#ff9128">**[AI]**</span>: Cloud processing (LLM Inference).
* <span style="color:#ff5050">**[!]**</span>: Error reporting (e.g., "Target not found").
* <span style="color:#32b4ff">**[CHAT]**</span>: AI Assistant response.



**🧠 Context Injection**

* **Dynamic Awareness:** Reads the current server's player list dynamically. The AI knows the difference between "Ben_123" and "BennyGamer" based on who is actually present.
* **Recursive Error Correction:** If the AI hallucinates a target, the script catches the error locally, feeds it back with a `[FEEDBACK ERROR]` tag, and retries automatically.

---

### 📜 Changelog

#### **Version 1.1 Final (Current)**

* **Logic Engine:**
* **Hybrid Model:** Introduced `FastMap` to handle 100+ standard commands locally, reserving the AI for complex natural language queries.
* **Optimization:** Reduced latency from ~1200ms to **0ms** for 95% of commands.
* **Full Dictionary Integration:** Integrated the complete Infinite Yield command syntax (Movement, Visuals, Tools, Server) into the local processor.


* **User Interface:**
* **Mobile Support:** Fixed GUI scaling issues on mobile devices (moved from 95% to 80% width).
* **Status Bar:** Added a text-based status indicator to show execution source (`[FAST]` vs `[AI]`) and error messages.
* **Performance:** Removed heavy image assets and shadows for a cleaner "Flat Glass" aesthetic that renders faster.



#### **Version 1.1 Stable (Previous)**

* **System Architecture:**
* **Recursive Error Correction:** Added a feedback loop that validates targets.
* **Knowledge Base:** Integrated rigid syntax dictionaries for basic commands to reduce AI hallucinations.


* **Stability:**
* **Bridge Timeout:** Added a 10-second timeout to the connection bridge.
* **Async Fetching:** Game name fetching is now asynchronous.



#### **Version 1.0**

* Initial release with basic "Input -> API -> Output" linear logic.
* Introduced the Glassmorphism UI and Dual Mode (CMD/CHAT) concepts.
* Established the foundational "Bridge" injection method.

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

**SmartInfiniteYield V1.1** solves the "Hallucination" problem common in AI scripts using a **Validation-Retry Loop**:

1. **Input:** User types "Goto vol".
2. **Context:** Script grabs current player list (e.g., `[VolQ5, Player2, Player3]`).
3. **Prompting:** Sends request + player list to AI.
4. **Validation:**
* *Scenario A:* AI returns `;goto VolQ5`. Target exists. **EXECUTE.**
* *Scenario B:* AI returns `;goto Volcano`. Target missing. **HALT.**


5. **Recursion (If Scenario B):**
* Script sends: `[FEEDBACK ERROR: Target 'Volcano' not found.]`
* AI Retries: "Ah, looking at the list, it must be VolQ5." -> Returns `;goto VolQ5`.
* **EXECUTE.**



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
