# JUDAS PROTOCOL
**Global Game Jam 2026 Submission**
**Team:** Krishna Gupta & Co.

## 🎮 The Concept
Judas Protocol is a psychological horror shooter where the protagonist's reality—and the game engine itself—is unstable. We are deconstructing the standard shooter mechanics to create a "Sanity Engine."

## 🛠 Tech Stack & Assets
* **Engine:** Godot 4.x
* **Base Framework:** Godot Official TPS Demo (Used for core locomotion and environment assets)
* **Custom Systems:**
    * **Glitch/Sanity Shader:** Custom GLSL rendering pipeline.
    * **DevGym Environment:** Greybox testing facility for sanity mechanics.
    * **Reality Switching:** Dynamic world-state toggling.

## 📂 Key Files (Judge Review)
If you are looking for our custom code, please check:
* `glitch.gdshader` (The visual tearing engine)
* `dev_gym.gd` (The reality manager)
* `DevGym.tscn` (The prototype scene)