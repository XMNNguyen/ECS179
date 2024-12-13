# The title of your game #

## Summary ##

**A paragraph-length pitch for your game.**

## Project Resources

[Web-playable version of your game.](https://itch.io/)  
[Trailor](https://youtube.com)  
[Press Kit](https://dopresskit.com/)  
[Proposal: make your own copy of the linked doc.](https://docs.google.com/document/d/1qwWCpMwKJGOLQ-rRJt8G8zisCa2XHFhv6zSWars0eWM/edit?usp=sharing)  

## Gameplay Explanation ##

**In this section, explain how the game should be played. Treat this as a manual within a game. Explaining the button mappings and the most optimal gameplay strategy is encouraged.**


**Add it here if you did work that should be factored into your grade but does not fit easily into the proscribed roles! Please include links to resources and descriptions of game-related material that does not fit into roles here.**

# Main Roles #

* Producer : Ian O'Connell
* Game Logic : Martin Nguyen 
* Animation and Visuals : Charlie Edwards 
* User Interface and Input : Jason Gao 
* Movement/Physics : Cyrus Azad 

Your goal is to relate the work of your role and sub-role in terms of the content of the course. Please look at the role sections below for specific instructions for each role.

Below is a template for you to highlight items of your work. These provide the evidence needed for your work to be evaluated. Try to have at least four such descriptions. They will be assessed on the quality of the underlying system and how they are linked to course content. 

*Short Description* - Long description of your work item that includes how it is relevant to topics discussed in class. [link to evidence in your repository](https://github.com/dr-jam/ECS189L/edit/project-description/ProjectDocumentTemplate.md)

Here is an example:  
*Procedural Terrain* - The game's background consists of procedurally generated terrain produced with Perlin noise. The game can modify this terrain at run-time via a call to its script methods. The intent is to allow the player to modify the terrain. This system is based on the component design pattern and the procedural content generation portions of the course. [The PCG terrain generation script](https://github.com/dr-jam/CameraControlExercise/blob/513b927e87fc686fe627bf7d4ff6ff841cf34e9f/Obscura/Assets/Scripts/TerrainGenerator.cs#L6).

You should replay any **bold text** with your relevant information. Liberally use the template when necessary and appropriate.

## Producer ( Ian O'Connell ) 

**Describe the steps you took in your role as producer. Typical items include group scheduling mechanisms, links to meeting notes, descriptions of team logistics problems with their resolution, project organization tools (e.g., timelines, dependency/task tracking, Gantt charts, etc.), and repository management methodology.**

## User Interface and Input ( Jason Gao ) 

**Describe your user interface and how it relates to gameplay. This can be done via the template.**
**Describe the default input configuration.**

**Add an entry for each platform or input style your project supports.**

## Movement/Physics ( Cyrus Azad ) 

**Describe the basics of movement and physics in your game. Is it the standard physics model? What did you change or modify? Did you make your movement scripts that do not use the physics system?**

## Animation and Visuals ( Charlie Edwards ) 

**List your assets, including their sources and licenses.**

Necromancer - [Source](https://thestoryteller01.wordpress.com/2015/01/02/skeleton-sprites-6-for-rpg-maker-xp/), Creative Commons Attribution 4.0 International License (CC BY 4.0) with credit to Enterbrain, Ice-Ax and Sebastien Bini

Dog (Lucky) - [Source, Modern Interior Pack](https://aurora-sprites.wixsite.com/main/sets?lang=en), CC BY-NC 4.0

Trolls - [Source](https://opengameart.org/node/78138), Creative Commons Attribution (CC BY) version 3.0

Chickens - [Source](https://opengameart.org/node/11629), Attributed to Daniel Eddeland

Sprout - [Source](https://chiecola.itch.io/won-won-drone), Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)

Boss - [Source](https://opengameart.org/content/bosses-and-monsters-spritesheets-ars-notoria), Creative Commons Attribution (CC BY) version 3.0 with credit to Stephen Challener (Redshrike)

Projectiles - [Source](https://bdragon1727.itch.io/free-effect-and-bullet-16x16), Free to use on non-commercial games

Tileset - [Source](https://opengameart.org/content/isometric-64x64-outside-tileset), Creative Commons Attribution 4.0 International License (CC BY 4.0) with credit to Yar

Hearts - [Source](https://pixel-boy.itch.io/ninja-adventure-asset-pack), Creative Commons Zero (CC0) 

Potions - [Source](https://opengameart.org/content/potion-bottles), Creative Commons Zero (CC0)

Sign - [Source](https://game-endeavor.itch.io/mystic-woods), Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)


**Describe how your work intersects with game feel, graphic design, and world-building. Include your visual style guide if one exists.**

To establish a cohesive game feel, I carefully selected pixel art assets from free resources that harmonize stylistically, maintaining a consistent isometric perspective and level of detail. In order to keep the game feeling fair, it was important to choose enemies and projectiles that could be quickly and clearly seen. Dense foliage outlining the path creates an immersive environment that also works toward leading the player in the right direction. 
I also utilied Godot's particle system to create smoke and energy effects to give the Boss magical powers to futher establish the setting of the game.

## Game Logic ( Martin Nguyen ) 

**Document the game states and game data you managed and the design patterns you used to complete your task.**

# Sub-Roles

* Press Kit and Trailer : Ian O'Connell
* Game Feel and Polish : Martin Nguyen 
* Narrative Design : Charlie Edwards 
* Audio : Jason Gao 
* Gameplay Testing : Cyrus Azad 

## Audio ( Jason Gao ) 

**List your assets, including their sources and licenses.**

**Describe the implementation of your audio system.**

**Document the sound style.** 

## Gameplay Testing ( Cyrus Azad ) 

**Add a link to the full results of your gameplay tests.**

**Summarize the key findings from your gameplay tests.**

## Narrative Design ( Charlie Edwards ) 

**Document how the narrative is present in the game via assets, gameplay systems, and gameplay.** 

I utlized the Godot plugin Dialogue Manager to assist with creating dialogue and to have the option for branching dialogue trees. [Source](https://github.com/nathanhoad/godot_dialogue_manager/tree/main), [License](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/LICENSE)

Dialogue Manager lets me manage all of the game's dialogue in a single text file, where I can sequentially call dialogue and functions. Since we do not have any voice acting, I used pictures in the dialogue box to show who is talking. The player is allowed to move during dialogue because some signs, containing dialogue, are placed where enemies may be present; so we decided it was best to always let the player move during dialogue. 

The introduction cutscene gives the context of the game and makes it clear early on that this is a light-hearted game, not meant to be taken too seriously. The death of the dog, Lucky, establishes the motivation of the Necromancer's rampage, gives a reason for the player to try to beat the game and reunite the Necromancer and Lucky, and shows how despicably evil the boss is.

I also chose to put an interactable sign right after the first cutscene, at the start of the gameplay, to build ituition in the player to interact with any futures signs they see. Interacting with a sign is necessary in order to start the boss fight later.

This first sign just has a simple beware of enemies message that serves to warn the player of future enemies, but mainly is there to make the player want to interact with signs.

The second sign is found right before the boss fight and starts the fight. 

## Press Kit and Trailer ( Ian O'Connell ) 

**Include links to your presskit materials and trailer.**

**Describe how you showcased your work. How did you choose what to show in the trailer? Why did you choose your screenshots?**

## Game Feel and Polish ( Martin Nguyen ) 

**Document what you added to and how you tweaked your game to improve its game feel.**
