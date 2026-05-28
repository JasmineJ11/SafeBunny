# Safe Bunny

A scenario-driven 2D Android platformer that teaches children aged 6–12 to stay safe online — through real cybersecurity choices with immediate consequences.

Bachelor's Thesis project · HAMK University of Applied Sciences · 2026

> **Status:** Currently in closed testing on Google Play (Alpha). Access requires an invite.
>
> **Download:** [v1.0.0-alpha APK](https://github.com/JasmineJ11/SafeCat/releases/tag/v1.0.0-alpha)

---

## Demo

https://github.com/user-attachments/assets/13eea050-aa0c-4434-a6a3-523f73086ec3

---

## Theory

The theoretical part of reviewed children needs and risks about their cybersecurity and the limits of the present educational approaches. It was based on the theory of gamification, the theory of experiential learning and the positive feedback loop to build a design. Five content dimensions were derived.

---

## Safety content

| Level | Topic | Scenario |
|-------|-------|----------|
| 1 | Privacy protection | Keep personal information safe from strangers |
| 2 | Phishing | A treasure chest offers a reward — but it's a trap |
| 3 | Password safety | A monster attacks — build a strong password to fight back |
| 4 | Cyberbullying | Recognise and respond to harmful online behaviour |
| 5 | Digital kindness | Help a sad kid, earn a heart |

---

## Stack

| | |
|---|---|
| Engine | Godot 4 |
| Language | GDScript |
| Platform | Android (Google Play — Closed Testing / Alpha) |
| Export | AAB · Release Keystore signed |
| Data | Local JSON save file — no external server |

---

## Architecture

- **Modular Scene Tree** — each game object (player, NPC, enemy, hazard) is its own scene, composed at runtime
- **GameManager singleton** — global state, score tracking, level transitions
- **Signal-based event system** — loose coupling between scenes; interactions (coin collected, checkpoint reached, dialogue triggered) are broadcast via signals
- **SaveManager** — reads and writes progress to a local JSON file; no network calls, no accounts (Privacy by Design)

---

## Project Structure

```
scripts/
├── player.gd           # Movement, jump, collision
├── game_manager.gd     # Global state, scoring, level flow
├── saveManager.gd      # JSON-based local save/load
├── npc.gd              # Dialogue-triggering NPCs
├── bully_message.gd    # Cyberbullying scenario logic
├── treasure_chest.gd   # Phishing trap scenario
├── sad_kid.gd          # Digital kindness interaction
├── monster.gd          # Enemy AI
├── red_slime.gd        # Enemy variant
├── slime.gd            # Enemy variant
├── check_point.gd      # Checkpoint save trigger
├── coin.gd             # Collectible
├── killzone.gd         # Death / reset zone
└── goal.gd             # Level completion trigger

scences/               # .tscn files for each object above
assets/
├── sprites/
├── fonts/
├── music/
└── sounds/
```

---

## Getting Started

1. Install [Godot 4](https://godotengine.org/)
2. Clone the repository
3. Open `project.godot` in Godot
4. Press **F5** to run

To build for Android, configure the export preset in `export_presets.cfg` with your own keystore.

---

## Privacy

No data leaves the device. Player progress is saved to a local JSON file only. No accounts, no analytics, no network requests.
