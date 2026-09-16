# Contributing to the Modular Platform Asset Pack

First off, thank you for considering contributing to this project! It is people like you who make the open-source community great.

To ensure this asset pack remains high-quality, organized, and optimized, please read and follow these guidelines strictly before submitting a Pull Request (PR).

## Naming & File Rules

Consistency is mandatory. Name your files exactly like this:

- **Folders, Scenes, and Code Files**: Must use **PascalCase** (e.g., MovingPlatform, LevelManager).

- **Node Icons**: Must use **snake_case** (e.g., platform_icon.svg).

    * **Format**: `.svg` files only.

    * **Dimensions**: Must be perfectly square and a maximum size of 26x26px and minimum size of 16x16px.

    * **Color Theme**: Must strictly follow Godot's default node color system to match the parent node type (`#fc7f7f` for Node3D, `#8da5f3` for Node2D, `#8eef97` for Control/UI, `#c38ef1` for animation, `#ffca5f` for Engine and `#e0e0e0` for Node).

- **Textures and Sprites**: Must use descriptive **snake_case** (e.g., metal_platform_diffuse.png). Do not submit files with default or random names.

## Architecture & Code Standards

To keep the codebase scalable and predictable, strict inheritance is mandatory:

- **Platforms**: All new platforms must inherit from the base Platform class (or an existing platform subclass).

- **Hazards, Props, and Triggers**: The exact same inheritance rule applies. You must extend the respective base class for the object type you are creating. Do not create isolated, standalone scripts for these objects.

- **Use UIDs**: Always use uid for referencing files to prevent path breakage if assets are moved.

## Folder Structure

Place your files in the correct directories. Do not dump everything in the root folder.

- **Strict Isolation**: Every single new platform, hazard, prop, or trigger must have its own dedicated folder. Do not mix assets from different objects into the same directory.

- **Textures and Sprites Paths**: Must be placed strictly inside the matching platform or props folder using the following directory structure:

[PlatformOrPropName]/Textures/SpriteFrames/

[PlatformOrPropName]/Textures/Sprites/

## How to Submit Your Changes

If you are new to GitHub or open-source, don't worry! Here is the step-by-step process to submit your work:

1. **Fork the Repository:** Click the "Fork" button at the top right of this GitHub page to create a personal copy of this project on your own account.
2. **Create a Branch:** Download your fork to your computer (using GitHub Desktop or the command line). Create a new, cleanly named branch for your specific addition. 
    * *CLI command:* `git checkout -b feature/moving-platform`
3. **Make Your Changes:** Add your new folders, code, or assets into the Godot project. Ensure you follow all the naming and architecture rules above.
4. **Commit:** Save your changes with a clear, short description of exactly what you built.
    * *CLI command:* `git commit -m "Added MovingPlatform node"`
5. **Push & Pull Request:** Upload (push) your branch back to your GitHub account. Then, go to the original repository and click the green "Compare & pull request" button to submit your assets for review.
    * *CLI command:* `git push origin feature/moving-platform`

## Pull Request Requirements

When you open a PR, you MUST include:

A brief description of what you added or fixed.

At least one screenshot of your asset rendered or placed inside the Godot engine to prove it works.

If your PR does not meet these guidelines, I will request changes before merging it.