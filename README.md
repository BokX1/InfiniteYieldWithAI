# SmartInfiniteYield (SIY) - V1.1 Stable+CloudFlare

**Original Idea by VolQ5 | Powered by Pollinations.AI (Grok/Gemini Model)**

**SmartInfiniteYield** is an open-source, next-generation wrapper for the popular Roblox admin script, Infinite Yield. Unlike standard wrappers, SIY implements a **Self-Correcting Logic Engine** that translates natural language into precise execution strings.

It features a **Recursive Feedback Loop**: if the AI targets a non-existent player or generates invalid syntax, the script detects the error, injects the correct server context, and forces the AI to fix its own mistake before executing.

The API is protected by CloudFlare to prevent bad actor (abuse)

### ⚡ Key Features

**🧠 Awareness**

* **Context Injection:** The script reads the current server's player list dynamically. If you say "Goto ben," it knows whether you mean "Ben_123" or "BennyGamer" based on who is actually in the server.
* **Recursive Error Correction:** If the AI generates a bad command (e.g., typos a username), the script catches the error, feeds it back to the AI with a `[FEEDBACK ERROR]` tag, and retries automatically.
* **Knowledge Base:** Hardcoded syntax dictionaries for Movement, Visuals, and Admin commands ensure the AI adheres to strict Infinite Yield syntax.

**🛡️ The "Bridge" Architecture**

* Uses a custom **Source Injection** method to hook directly into Infinite Yield's internal `execCmd` function.
* **Bridge Timeout:** Includes a failsafe mechanism to prevent the script from hanging if the bridge takes too long to initialize.

**📱 Modern UI (V1.1)**

* **State Indication:** The input box provides real-time feedback:
* <span style="color:#00ff00">**Thinking...**</span> (Green): Generating initial command.
* <span style="color:#ff8c00">**Fixing...**</span> (Orange): Auto-correcting an invalid target/syntax.


* **Glassmorphism Design:** Sleek dark mode with animated `UIStroke` pulses.
* **Floating Icon:** Minimizes to a subtle brain-chip icon to save screen space.

**☯️ Dual Modes**

* **CMD Mode (Orange):** Translates text directly into commands with strict validation.
* **CHAT Mode (Blue):** Acts as a Game Assistant. Ask questions like *"How do I win this?"* The AI detects the Game Name and provides specific advice via Notifications.

---

### 📜 Changelog

#### **Version 1.1 Stable (Current)**

* **System Architecture:**
* **Recursive Error Correction:** Added a feedback loop that validates targets. If a target is invalid, the system automatically retries with corrected data.
* **Context Injection:** Commands involving players now dynamically inject the current server player list into the prompt for higher accuracy.
* **Knowledge Base:** Integrated rigid syntax dictionaries for `[MOVEMENT]`, `[VISUALS]`, and `[ADMIN]` commands to eliminate hallucinations.


* **UX & Visuals:**
* **Status Indicators:** Added "Fixing..." (Orange) state to indicate when the AI is self-correcting an error.
* **UI Polish:** Added animated pulse effects during processing and updated the Tutorial Modal.
* **Chat Mode:** Cleaned up output to remove prefixes for a more natural assistant experience.


* **Stability:**
* **Bridge Timeout:** Added a 10-second timeout to the connection bridge to prevent execution freezes.
* **Async Fetching:** Game name fetching is now asynchronous to prevent UI locking.



#### **Version 1.0**

* Initial release with basic "Input -> API -> Output" linear logic.
* Introduced the Glassmorphism UI and Dual Mode (CMD/CHAT) concepts.
* Established the foundational "Bridge" injection method for Infinite Yield.

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
