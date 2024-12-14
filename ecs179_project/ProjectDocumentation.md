# Necromancer Roguelike #

## Summary ##

Necromancer's Burden is a roguelike action game where the player controls a Necromancer who's dog Lucky has just died of old age. The Necromancer has the dark intention of collecting the souls of the innocent in the hope of becoming powerful enough to collect the components required to bring Lucky back.

Defeat various enemies to collect their souls and become more powerful. Unlock new abilities to aid when exploring the world and confronting challenging bosses. Embark on a dangerous and certainly not justified murder rampage so Lucky can bark once again!

## Resources

## Gameplay Explanation ##

Necromancer's Burden is a roguelike action game where the player can play through a forest themed level. The player starts on an island and can interact with Lucky by pressing spacebar. After this the player can work their way through the forest defeating various enemies along the way. Control the necromancer with WASD movement controls and interact with signs by pressing spacebar. Attacks are unlocked as you collect souls from the enemies you defeat. Once attacks are unlocked they wil be shown at the bottom of the screen along with a cooldown to indicate when they will trigger next which is done entirely automatically requiring no input from the player. 

Chickens and Trolls have charge attacks. The flying sprout enemies have a ranged attack. When a player is hit there is some screenshake to indicate you have taken damage. When an enemy is hit there are some blood particles and audio effects indicating this has happened. Occassionaly enemies will drop red orbs that can be picked up to regenerate health. At the end of the forest is a sign that can be interacte with using spacebar to start the boss encounter. The boss has ranged attacks that restrict player movement if you are hit in addition to hoardes of enemies at his side. 

# Main Roles #

* Producer : Ian O'Connell
* Game Logic : Martin Nguyen 
* Animation and Visuals : Charlie Edwards 
* User Interface and Input : Jason Gao 
* Movement/Physics : Cyrus Azad

## Producer - Ian O'Connell

Much of the scheduling responsibilities were a coordinated effort involving all members of the group. Everyone attended and contributed to all the group meetings. We had our initial plan meeting which involved mostly brainstorming and setting some basic goals for what we wanted to accomplish. In hindsight these goals were a bit ambitious but it's better to aim high than low. We had another group meeting to create the progress report where we assessed where we were at and set some new more realistic and attainable goals. The goals we set in the progress report were accomplished over the following week or two. Throughout this process we utilized discord as our priamry form of communication where we frequently communicated about what we were working on, what kinds of decisions we were making, and what we needed to do next. 
- **Initial Plan** : https://docs.google.com/document/d/1QqzLDletkXFg4AImwJFmtnuPc1e0cuPF3647ZCGJzTY/edit?tab=t.0#heading=h.i3tv2mxf7h7z
- **Progress Report** : https://docs.google.com/document/d/1Y2GFw5OVA8qR6Pvmf4Iat8glOY2byfNlwOCEWyuxpnI/edit?tab=t.0#heading=h.aafu4y4mcm30

Original Plan : 

![image](https://github.com/user-attachments/assets/05c1cd66-75e7-4a1b-b6a1-0a64f56f9e41)
![image](https://github.com/user-attachments/assets/058798a5-80a5-4c66-acb1-c8de86df6051)

Adjusted goals during progress report meeting : 

![image](https://github.com/user-attachments/assets/c3aafc94-6f3c-4e1a-9085-d954935fef09)

The communication in discord can be seen in these examples : 

![image](https://github.com/user-attachments/assets/37185533-14eb-48c3-9caa-c59c72289443)
![image](https://github.com/user-attachments/assets/cc71b1ee-6fe3-4d64-8f0b-4a07e38ea5b2)
![image](https://github.com/user-attachments/assets/8534a9d0-5ba4-4635-8ca9-2315ca2f76ed)

We used a clickup list to clearly display the goals set at the progress report meeting (Martin's idea). Contributions to the repository were done methodically and one at a time to ensure there were no conflicts between the work done by different group members. We also divided the work in ways that made collisions less likely. We never had to deal with any issues within the repository. 
- **ClickUp** : https://app.clickup.com/9011732114/v/l/li/901107402691

I managed uploading the web playable version of the game on itch.io which can be found at https://braxai.itch.io/necromancers-burden. 

I worked on the map. Building the level the player would navigate and discussing ideas behind what enemies would be present, where they would be, and how the boss fit into the level. I helped collect asset packs and develop the visual direction the game was going. This included finding the terrain packs, the dog pack, the packs used for the boss and the packs for some of the enemies. 

## Game Logic - Martin Nguyen

Note: Even though this was my main role, there were some aspects of game logic that everyone worked on together.

### Isometric Tile Logic

Since we were implementing an isometric game using a 2D Godot scene, isometric movement/logic needed to created from scratch. In order to implement isometric movement, we needed to add the illusion of the world being 3D. I sectioned this off into 2 main parts.

1. Moving on slopes

One of the first things I did while implementing slope movement was classify all of the slope tiles based on the direction they are facing. This can be seen
[here in tile_map.gd. ](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/tile_map.gd#L31)
Afterwards, I implemented the different ways that a player can move up a slope based on type. 

The first main type is a slope going directly verticle. To give the illusion of moving on the y axis, all I did was apply a slowdown whenever the player moved up or down making it look like the player is actually climbing a hill instead of moving on a flat plain.

The 2nd main type is a slope with some form of horizontal movement. Just like with the verticle movement, I applied a slowdown whenever the player is moving "up" a slope. For each of the slope types, to create illusion of moving on the slope I needed to apply a y-bias on the character's velocity.y in order to move up a hill. For example lets say we are moving horizontally on a slope tile that is moving up and to the right. Technically if we were to look at it through the character's eyes in 3D, they are moving diagonally up a hill. There are varying y-bias values based on if we are moving on a diagonal slope, horizontal slope, and if we are moving either up or down the slope. However, there is still a bug regarding y_sort in my implementation. Whenever we try to move up a slope that is behind another tile, it looks really janky since the player clips throught the floor and pops up on top of the hill. This is definitely something I would've liked to fix if time permitted, but I decided to focus more on the core gameplay first since I believed polishing that was more important.

This logic can be seen in the 
[move_on_slope method in player.gd, enemy.gd, or boss.gd.](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/player.gd#L374)

2. Distinguishing layers

Basically, since we are using a layering system for our tileset, we need a way for our characters to change layers whenever they move to a new one. Without this, our characters will stay on the same layer and basically be able to glide through layers that are above. 

In order to accomplish this, the first thing I made was a method to change a character's z_index, which can be seen
[here in the adjust_z_index method in player.gd, enemy.gd, or boss.gd;](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/player.gd#L345)
Basically whenever this method is called, we check the tile the character is on based on the head's position. It will go through each layer from top to bottom and it will set our character's z_index to be the layer_number + 1 of the 1st block/slope tile type we find. For the player this function is called whenever we first enter and exit a slope tile. For enemies and bosses, we just have it called on every process. This mainly worked since enemies were mostly all small. 

Another thing that is done is that based on the player's layer, we create a custom collision border around the map. Technically, we could just set up collision shapes for each tile, however this leads to way to many combinations of tiles + layers to handle. To make this easier I created a method to handle the logic behind placing the boundery tiles. The first thing I did was create and classify different collision barrier tile types seen
[here in tile_map.gd. ](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/tile_map.gd#L15)

The first thing we check is the floor the player is on. On the floor layer, I iterate through every tile and for each tile, check the adjacent tiles. If any adjacent tiles are an empty tile, place a full sized boundery tile on it. The second thing is to check the current layer the player is on. We iterate through all tiles in the layer and if a block type block is found, check adjacent tiles to see if they are empty. To determine the type of wall barrier tile to place, I use a Vector4 to obtain and store any existing adjacent tiles as seen 
[here ](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/tile_map.gd#L128)
and with this information, we obtain the atlas coords from the wall_bounderies dictionary using this vector as our key and place the tile.
The code can be seen
[here in the setup_boundery method. ](https://github.com/XMNNguyen/ECS179/blob/95dcc2b0a58341a5020da4d386e76533cbe942f1/ecs179_project/Scripts/tile_map.gd#L103)
Now, whenever a player moves into a new layer, we clear the old boundery tiles and create a new boundery based on what layer the player is on.

Overall, isometric logic came out pretty well.

| Before | After |
| :------------: |:------------: |
|<img src="https://github.com/user-attachments/assets/ebb86ace-66bd-4edd-944e-4e1f46f6a282" width="300" height="300" /> | <img src="https://github.com/user-attachments/assets/44cb1e3d-f1b2-44d8-9140-c6730f55077d" width = "300" height ="300"/> | 

### Enemy Logic
All enemies that I created were made with a CharacterBody2D. The first thing I did was create the base Enemy class 
[found here. ](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/enemy.gd)
The base enemy class has all methods needed to move on the isometric map, can die, can have their stats distributed based on level (logic found later in Leveling Logic section), and can drop objects. Our game has 3 main different enemy types.

1. [Chicken](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/chicken.gd)

The chicken is the most basic enemy type that I created. The main job of this enemy is to only act as a minor obstacle for the players to overcome. The main attack pattern involves,
- Following the player when aggro is on. Aggro is triggered when the distance between player.global_position and chicken.global_position <= aggro_range
- Charging at the player when attack is triggered. There is a small period of time where the chicken stands still and when charging, we slowly reduce velocity. The attack ends when velocity is less then 10 in both y and x directions.
  
2. [Sprout](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/sprout.gd)

Just like the chicken, this enemy was designed to be a very basic enemy type. This enemy is meant to be a ranged type enemy that fires small pellets at the player. The main attack pattern involves,
- Following the player when aggro is on. Same logic as before.
- Stopping and start firing at the player when attack is triggered. I decided to make the shooting attached to the firing animation instead of a traditional cooldown with a timer. This way, the firing animation and the actual firing of the bullet is always in sync.
  
3. [Troll](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/troll.gd) 

The troll is meant to be a slightly larger obstacle for the players to deal with. To achieve this, I made the attack pattern exactly the same as the chicken's attack pattern, but with an added stun when the player is hit. The main attack pattern involves,
- Following the player when aggro is on same as before.
- Charging at the player when attack is triggered. Same logic as chicken.
- When hitting the player, initiate a stun on the player and have the troll hug the player. To determine stun length, a timer is created which is then forwarded to the player using a signal as seen
[here in the stun method](https://github.com/XMNNguyen/ECS179/blob/619aba6051a728cd3dd510c0312a0aabe96c647d/ecs179_project/Scripts/Enemies/troll.gd#L140)
When player is stunned, they are not allowed to fire or move.

|Chicken |Sprout |Troll |
| :------------: |:------------: |:------------: |
|<img src="https://github.com/user-attachments/assets/61ed009e-23bf-4eff-a5c4-31103b173a42" width = "300" height ="250"/> | <img src="https://github.com/user-attachments/assets/2d62c025-7d75-483f-beaf-e85b4605751a" width = "300" height ="250"/> | <img src="https://github.com/user-attachments/assets/24ca2a58-6db2-4ff6-8de5-6eb6a6b337b8" width = "300" height ="250"/>|

### Spawner logic

For spawners, because we went with a linear style of game, I decided to make the enemy spawner a placeable object. By making the spawner a placeable object, it allows us to scale the levels of enemies to create a difficulty curve. Basically a spawner has a random set of enemies that can spawn from them. When the player is in range and it is off cooldown, it will spawn a set number of enemies within the spawn area. 

The [spawn logic](https://github.com/XMNNguyen/ECS179/blob/219c6ff7f2aa607a5b7fe5579ab086922b8a96c3/ecs179_project/Scripts/spawner.gd#L43) 
is the following:
1. Get a random enemy scene path from enemy_types[] and then load it as an enemy.
2. Assign the enemy a level based on spawner level and then call assign_stats to randomly distribute the enemy stat points
3. Get a valid spawn location based on if the enemy is within spawn range, not on an empty tile, and not on top of the player and place them there 

### Weapon Logic

For our weapon, our player is able to unlock and fire various different types of bullets. Whenever the 
[fire method](https://github.com/XMNNguyen/ECS179/blob/a16a79008af77f4103f4b34434faf031295457b3/ecs179_project/Scripts/player.gd#L198)
is called, the player will try to fire each of the different types of bullets and bullets are only fired if they are unlocked and the bullet is off cooldown. The weapon will automatically fire bullets based on the closest enemy to the player. To determine the closest enemy, we have to iterate through all nodes within the "Enemies" group and check their positions compared to the player's position. This can be seen 
[here in the get_closest_enemy_position method](https://github.com/XMNNguyen/ECS179/blob/a16a79008af77f4103f4b34434faf031295457b3/ecs179_project/Scripts/player.gd#L179)
There are 5 main types of bullets

1. [Standard Bullet](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Attacks/standard_bullet.gd)

[**Base Stats**](https://github.com/XMNNguyen/ECS179/blob/2f9af55c9d96b8494b98b073140d522b0ef886c8/ecs179_project/Scripts/player.gd#L20)

This is the base weapon for our player. When fired, a single bullet will come out and then go in the direction of the closest enemy. It will do damage on contact with the enemy's hurtBox.
  
2. [Shotgun Bullet](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Attacks/shotgun_bullet.gd)

[**Base Stats**](https://github.com/XMNNguyen/ECS179/blob/2f9af55c9d96b8494b98b073140d522b0ef886c8/ecs179_project/Scripts/player.gd#L33)

This is the 2nd weapon that the player will unlock. When fired, it will fire a volley of bullets towards the nearest enemy. 

To determine each bullet's firing direction, I went with an iterative approach where I iterate through each bullet and even spread them throughout an angle. First we determine the current angle for our bullet, this is calculated by dividing the angle by the number of bullets and then multiplying it by our current bullet number. This is added to the current firing directionn angle. We then need to rotate the bullet angle by angle / 2. If we do not rotate the angle, our shotgun would be firing 1 bullet in the firing direction, and then the rest of the bullets will fan out all in the same direction instead of having the center of the fan be our firing direction.

This code can be seen
[here in fire_shotgun](https://github.com/XMNNguyen/ECS179/blob/718d8775caa66c48ed5cba3c95c274b95ab08708/ecs179_project/Scripts/player.gd#L252)
  
3. [Wave Bullet](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Attacks/wave_bullet.gd)

[**Base Stats**](https://github.com/XMNNguyen/ECS179/blob/2f9af55c9d96b8494b98b073140d522b0ef886c8/ecs179_project/Scripts/player.gd#L27)

This is a melee AOE style of bullet. Basically, we fire 4 different instances of our wave bullet in each cardinal direction. This attack follows the player and can pierce enemies as well. This is the only bullet that doesn't change firing direction based on the closest enemy and instead is based on player position. It is one of the stronger aoe abilities that the player has, but because of its melee nature, there is a huge risk and reward for trying to hit enemies with this ability.

The fire implementation can be seen
[here in fire_wave](https://github.com/XMNNguyen/ECS179/blob/718d8775caa66c48ed5cba3c95c274b95ab08708/ecs179_project/Scripts/player.gd#L285)
   
4. [Scatter Bullet](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Attacks/scatter_bullet.gd)

[**Base Stats**](https://github.com/XMNNguyen/ECS179/blob/2f9af55c9d96b8494b98b073140d522b0ef886c8/ecs179_project/Scripts/player.gd#L40)

This is a grenade style of bullet that on hit, will fire multiple bullets in a 360 degree angle. The spread logic is the exact same as the shotgun bullet. Basically, we first fire a bullet with the will_scatter flag turned on. When this flag is on, on hitting an enemy, it will fire a number of scatter bullets in a 360 degree angle whith the will_scatter flag turned off. This algorithm can be seen
[here](https://github.com/XMNNguyen/ECS179/blob/38ee1b84ba4aba6d4b6cdd680bd01cf080555301/ecs179_project/Scripts/Attacks/scatter_bullet.gd#L51)
This is meant to be a more safer AOE alternative to the wave_bullet since it is ranged and can hit many enemies. Multiple bullets can hit the same enemy as well doing some massive single target damage.
   
5. [Chain Bullet](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Attacks/chain_bullet.gd)

[**Base Stats**](https://github.com/XMNNguyen/ECS179/blob/2f9af55c9d96b8494b98b073140d522b0ef886c8/ecs179_project/Scripts/player.gd#L45)

This is the final ability that the player can unlock and acts similarly to a chain lightning attack. I was inspired by 
[Diablo 2's Chain Lightning ability.](https://diablo.fandom.com/wiki/Chain_Lightning_(Diablo_II))
Basically when the bullet initially hits, it will do an instance of damage and then bounce mode is turned on. On each bounce, it will calculate the closest enemy position to the bullet. If it is within bounce range, the bullet rapidly travels to the enemy. If the bullet is not within bounce range, it will stick to the current target. Once the number of bounces exeeds num_bounces, we kill off the instance of our bullet. This logic can be seen
[here in the bounce method and _on_hit_box_area_entered method.](https://github.com/XMNNguyen/ECS179/blob/38ee1b84ba4aba6d4b6cdd680bd01cf080555301/ecs179_project/Scripts/Attacks/chain_bullet.gd#L67)

|Standard |Shotgun |Wave |Scatter |Chain | 
| :------------: |:------------: |:------------: | :------------: | :------------: |
| <img src="https://github.com/user-attachments/assets/36c567e6-743e-4093-88ee-e0d4e856ee22" width = "300" height ="300"/> | <img src="https://github.com/user-attachments/assets/db9f5ff7-ced1-40fc-922b-23f8d040d17c" width = "300" height ="300"/> | <img src="https://github.com/user-attachments/assets/92ff47cf-2382-41cc-8d83-414164e14e16" width = "300" height ="300"/> | <img src="https://github.com/user-attachments/assets/5cc0c743-3d08-4a34-b9f9-a4e60f6da317" width = "300" height ="300"/> | <img src="https://github.com/user-attachments/assets/ad2ee42a-adb6-4794-acd0-2e0ae1f0fdb7" width = "300" height ="300"/> |

### Leveling Logic

Orginally, we wanted to make a traditional leveling system where on level up, the player can select from a random set oof various different stat upgrades and powerups. However, we realized that we needed to scale down the game in order to meet the deadline. So for player leveling, we went with creating a psuedo leveling system with the weapons that were already made. Basically, as the player collects more souls, after certain threshholds, they will unlock a new ability. With this, it allowed us to focus on polishing the other aspects of our game.

We also gave enemies a hidden leveling system. By doing this, it allowed us to have a tool to increase the difficulty as players went through the level. Basically, for every level an enemy has, it gives them 1 stat point they can stand. For each stat point, we randomly allocate it into max_health, base_damage, or base_speed.

This can be seen
[here in enemy.gd](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/enemy.gd)

## Animation and Visuals - Charlie Edwards

****Assets Used****

- Necromancer - [Source](https://thestoryteller01.wordpress.com/2015/01/02/skeleton-sprites-6-for-rpg-maker-xp/), Creative Commons Attribution 4.0 International License (CC BY 4.0) with credit to Enterbrain, Ice-Ax and Sebastien Bini

- Dog (Lucky) - [Source, Modern Interior Pack](https://aurora-sprites.wixsite.com/main/sets?lang=en), CC BY-NC 4.0

- Trolls - [Source](https://opengameart.org/node/78138), Creative Commons Attribution (CC BY) version 3.0

- Chickens - [Source](https://opengameart.org/node/11629), Attributed to Daniel Eddeland

- Sprout - [Source](https://chiecola.itch.io/won-won-drone), Creative Commons Attribution-NonCommercial-NoDerivatives 4.0 International (CC BY-NC-ND 4.0)

- Boss - [Source](https://opengameart.org/content/bosses-and-monsters-spritesheets-ars-notoria), Creative Commons Attribution (CC BY) version 3.0 with credit to Stephen Challener (Redshrike)

- Projectiles - [Source](https://bdragon1727.itch.io/free-effect-and-bullet-16x16), Free to use on non-commercial games

- Tileset - [Source](https://opengameart.org/content/isometric-64x64-outside-tileset), Creative Commons Attribution 4.0 International License (CC BY 4.0) with credit to Yar

- Hearts - [Source](https://pixel-boy.itch.io/ninja-adventure-asset-pack), Creative Commons Zero (CC0) 

- Potions - [Source](https://opengameart.org/content/potion-bottles), Creative Commons Zero (CC0)

- Sign - [Source](https://game-endeavor.itch.io/mystic-woods), Creative Commons Attribution-NonCommercial 4.0 International (CC BY-NC 4.0)

### Game Feel

Note: Other team members also found assets to use. 

To establish a cohesive game feel, we selected assets from free resources that harmonize stylistically, maintaining a consistent level of detail as best as we could. Since our game can have many enemies and projectiles on screen at once, it was important to choose enemies and projectiles that could be quickly and clearly seen to keep the game feeling fair. This meant enemies needed to have distinct silohettes and colors while still fiting with the visual style. 

### Visual Style

We decided early on in development that we did not want this game to take itself too seriously, which we wanted to reflect in the visual style. This also worked in our favor while working with free assets as assets that slightly clashed with one another only added to the this goal of a not super serious game. 

The setting our game is a magical forest filled with a wide range of creatures. The main visual style was built around the tilemap that we found early on into development. All characters and items found throughout the game were selected with the tilemap in mind.  We initally planned on adding different environments, keeping the same style while introducing new textures, but due to time limitations we settled on the single environment. 

### World Building

I helped build the main world and built the island where the introduction cutscene takes place. One issue we noticed during play-testing was that some players had trouble following the linear level to the end. To address this problem we focused on making the scenary, like trees and bushes, better outline the intended path. This dense foliage outlining the path creates an immersive environment that also works toward leading the player in the right direction. 

![image](https://github.com/user-attachments/assets/1c650d40-8dd8-46c7-b915-a7a0d419f07a)

I also utilied Godot's particle system to create smoke and energy effects that are used during cutscenes. I wanted to establish that magic was a part of this world early on as the transition into firing magical orbs at the start of the gameplay felt a bit drastic without further context.

|<img width="449" alt="particles1" src="https://github.com/user-attachments/assets/2f673960-88de-40eb-b907-67a036bc273b" />|<img width="574" alt="particles3" src="https://github.com/user-attachments/assets/2a235781-7ac0-408b-8af1-dfa0b83a78c0" />|

## User Interface and Input - Jason Gao

Inputs:

-WASD for movement

-(space) to interact

-Mouse right click for interactions for press() in home screen, control screen, death screen and credits screen.

Starting, Controls, Death, and Credits Screen:

In all of these scenes, they use the same button graphic and functionality. The background of these scenes were photoshopped and implemented using the panel node in godot.

![image](https://github.com/XMNNguyen/ECS179/blob/18aee89737581bd5729f492e1759206b0f40f1c6/ecs179_project/READMEassets/Start_Screen.jpg)

Player Hearts:

The player has 8 hearts and has indices of 0.5, which totals to 16 health. Every time the health is at an odd number, it will display a half heart. The hearts are contained in a HBoxContainer so that each heart can be equally indented and individually customized by updating each individual child(each heart by frames in the sprite sheet) with indexes. This acts as a way to identify how much health is left. 

![image](https://github.com/XMNNguyen/ECS179/blob/18aee89737581bd5729f492e1759206b0f40f1c6/ecs179_project/READMEassets/Hearts_UI.jpg)

Souls Counter:

The soul is made by using a label node and an AnimatedSprite2D within a CanvasLayer. The label has a script that shows the amount of souls collected by getting the global script of souls_counter. This Graphic is used to determine how many souls you have collected, and how much you need to get the next ability.

![image](https://github.com/XMNNguyen/ECS179/blob/e883c44724cae16ea60c7550d9beeca014232ccb/ecs179_project/READMEassets/Souls.jpg)
![image](https://github.com/XMNNguyen/ECS179/blob/e883c44724cae16ea60c7550d9beeca014232ccb/ecs179_project/READMEassets/Souls_2.jpg)

Ability Cooldowns:

Much like the Player Hearts, the graphics for the ability cooldowns are also in a HBoxContainer, and each ability’s cooldown and graphic are updated through the indices of children. This is to help the player know when certain abilities are up to auto fire, so that it can be used for desired purposes, such as getting close to the boss when the shotgun ability is going to be up.

![image](https://github.com/XMNNguyen/ECS179/blob/e883c44724cae16ea60c7550d9beeca014232ccb/ecs179_project/READMEassets/Abilities_UI.jpg)
![image](https://github.com/XMNNguyen/ECS179/blob/e883c44724cae16ea60c7550d9beeca014232ccb/ecs179_project/READMEassets/Abilities_UI_2.jpg)


## Movement - Physics - Cyrus Azad
Note: Even though this was my main role, the rest of the group also helped implement some of the processes.

## Player Movement: 

The movement and physics in our game are very simple. The player is given 8 directional movement using the WASD keyboard keys, using the standard Godot movement systems of velocity and move_and_slide() in order to implement this. We had to make functions for the player to be able to move over a slope smoothly, called is_on_slope() and move_on_slope(), which was done by finding the tile data and adding a movement bias based on the input direction of the player and the type of slope they were on. We also added a helper function adjust_z_index to help keep the player walking on the surface instead of walking through the slopes and disappearing. 

## Enemy Movement/Attacks:

The enemy movement was implemented the same way, except instead of inputting directions the enemies locked on to and followed the player once the player was in range. We used vectors in order to calculate the direction of the player in reference to the given enemy so that the enemy knew which direction to move and/or attack. We also implemented different attacks for each enemy. Every time the player gets hit by an enemy attack, there is a stunlock where the movement of all enemies and players pauses, and there is an audio queue and camera shake in order to signify to the player that they took damage. The chicken starts a wind up timer once in attack range, and then launches it’s body at the player’s current position as a charge peck attack towards the player at a very increased velocity. The sprout fires a projectile at a given bullet_velocity in the direction of the player. For the troll, we made their attack very similar to the chicken with a wind up and charge, however when the troll hits the player it grabs them, stunning the player for a time given by the stun_timer. We made a signal to show the player that they are stunned and made the player have to be idle until the stun_timer is over. The boss attack is the same as the sprout’s in its movement and physics, but with different animation and stronger stats. 

## Player Abilities:

We also implemented different attacks with different physics mechanics. The base standard bullet simply fires a projectile at the nearest enemy. The shotgun weapon finds the nearest enemy, and then converts a given shotgun angle into radians, with the center of the angle being the location of the nearest enemy. It then divides the angle into different sections based on how many shotgun bullets there are, and fires the bullets in a spread shot within the angle given. The wave bullet is more of a pulse, as it uses vectors to send a short range wave of energy in each diagonal direction of the player, not accounting for enemy position at all. The chain bullet was very interesting to implement, as it shoots a bullet at the nearest enemy similar to the standard bullet, but then once an enemy is hit, it uses the enemy’s global position to find the next nearest enemy, and calculates if it is within a range of bounce_distance. If the enemy is within the range, the bullet then bounces and hits that next enemy, and then repeats for a given number of bounces. 

## Other Features:

We also had enemy drops, which consisted of souls and health drops, that gravitated towards the player once they were within a certain range. We used the lerp function to help the souls and health drops follow the player smoothly until they became in contact with the player model, on which then they "pop" and the player collects them. The player camera is a simple player lock camera that uses the lerpf function in order to make the camera shakes when a player gets hit feel like realistic shakes.

Each of the movement and physics mechanics described above are shown as visuals in Martin's Game Logic section. 


# Sub Roles #

* Press Kit and Trailer : Ian O'Connell
* Game Feel and Polish : Martin Nguyen 
* Narrative Design : Charlie Edwards 
* Audio : Jason Gao 
* Gameplay Testing : Cyrus Azad 

## Press Kit and Trailer - Ian O'Connell

I originally had a lot of apprehension with this role as I don't have much experience with the tools that are involved in developing a press kit and trailer. However, after going through the process of developing the game and creatively deciding how to best represent the decisions we made throughout that process I found this to be an enjoyable experience and am satisfied with the result.

### Press Kit
- [Press Kit](https://braxai.itch.io/necromancers-burden-presskit)
- I used itch.io to implement the press kit. I wanted the press kit to be as simple as possible and with us having implemented only the first major region of the game there isn't too much need for an extensive set of screenshots to represent the gameplay as is. I included an image of the home screen showing off some of the nice user interface work done by my teammates. Images of the Necromancer played by the character and Lucky the dog who serves as the motivation for the character's decision making are included. Finally a couple screenshots show what the gameplay can look like. A short summary gives the quick baseline of what the game is all about. Some simple information about the game and necessary methods to download and play the game are included as well. 

### Trailer 
- [Trailer](https://www.youtube.com/watch?v=0UQKqACdcuU)
- I wanted the trailer to have a somewhat ominous feel to match the idea that the Necromancer isn't necessarily a good guy. He is on a quest to bring Lucky back to life by any means necessary, including harvesting souls of the innovent. I found some spooky dark music to play in the background. It starts slow with the audio lower and builds up throughout the trailer. I tried to capture the idea that the Necromancer is an imposing character, collecting souls to become more powerful. The largest unbroken chunk of the trailer is the gameplay footage showing off what the enemies look like, how the attacks function, and what someone can expect when playing Necromancer's Burden. Then it fades out utilizing empty black screens and emphasizing the goal of bringing Lucky back. The audio volumne increases and syncs with the music to reveal the game title Necromacner's Burden at the end. The trailer is simple but gets across the main feelings intended to be included in the game.

## Game Feel - Martin Nguyen

### Vampire Survivor Inspiration

Since we wanted the game to be inspired by vampire survivors, we wanted the combat to feel close to vampire survivors as best as possible. There were 2 main decisions.

The first was the auto firing aspect. This allowed us to have multiple weapons without having to increase the skill cap of our game allowing players to always feel extremely powerful no matter the skill level.

The second was always having constant waves of enemies. The way we placed spawners on the map allowed for multiple waves of enemies to come from all different directions. This can create for some very explosive combat.

There is one decision that we made that was different from vampire survivor like games and that is to make our game a linear level instead of time based. The one thing I never liked about rogue likes is the fact that sometimes your build can get extremely messed up due to rng, making you not prepared for any of the bosses. By making our game linear, it allows players to take as much time farming to prepare what they need in order to fight the final boss. They can technically just fight whenver they want like for example speed running straight from the start to the end if they wanted too despite how hard we made the boss fight.

### Drop Collection

This is a very minor thing, but adding drops to our game made collecting exp much more fun. Basically, on death, enemies drop a soul. If the soul is close enough to the player, it will lerp towards the player and on contact, souls are addded to the player's soul count. Another drop are health pickups. I decided to make health pickups drop very frequently. This is because 1, there is no way to upgrade our hp so every point of hp is precious and 2, our hp pool is very low. A single half heart hit can feel like a lot so having these health drops drop frequently helps with lessening the load of needing to manage hp in a bullet hell setting.

[Here is the soul_drop code](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/soul_drop.gd)
and 
[here is the health_drop code](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/health_drop.gd)
### Hit Satisfaction

I broke down hit satisfaction into 3 different parts.

1. Shake (Camera Shake, Enemy Shake)

Shake is implemented in the following way. Whenever we signal to shake, the first thing we need to do is lerp our shake strength to 0. By lerping the shake strength to 0, this slowly lessens the shake until it stops. Afterwards, we randomly offset the camera in a random position with a max of shake strength distance away, creating our shake effect. There are 2 areas I added shake too, the camera and the enemy sprites. For the camera, I wanted shake to be fast and violent since it was the player that was getting hit. By doing this, it gives the player a notification that you were hit. For the enemy sprites, I wanted shake to be subtle, to make it seem as the enemy was slightly pushed by our attacks.

Camera shake is implemented 
[here ](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/player_camera.gd)
and enemy sprite shake is implemented
[here.](https://github.com/XMNNguyen/ECS179/blob/main/ecs179_project/Scripts/Enemies/enemy_shake.gd)

2. Time stop/slowdown

Time stop is implemented by setting our games time_scale below 1. Basically, we first set the time scale to some value below 1. Once we do that, we create a timer that is not effected by the time scale and after it stops, set the time_scale back to 1. Code can be seen 
[here in player.gd](https://github.com/XMNNguyen/ECS179/blob/c8cf44b20b05988b2cc3a684b109f717b32de225/ecs179_project/Scripts/player.gd#L474).
There are 2 areas that I apply time slowdown. The first is when the player gets hit. This is a very bullet hell style of rogue like so adding time slow after the player gets hit increases the feeling of impact by that hit. It also is a way to give a player a small break to process the information in front of them. This was especially important to have because of the bullet hell nature of this game. The 2nd area was on boss death. By slowing down time after the boss dies, it gives player time to process that the boss died since it is pretty hard to notice due to the sheer number of enemies on the screen at once. It also is just a cool effect to have overall.

3. Particles

For particles, I used godot's particle system. All particles that I created were made using 2DCpuParticle nodes. The main thing I wanted to add were blood effects for when players and enemies get hit. This is just another visual indicator that we hit/got hit and adds another level of impact. I also used Charlie's smoke particles after the boss was killed as well. Basically, I replaced all deleted enemies with smoke particles creating the look that they exploded. It was just overall satisfying to add.

| Player Hitstun | Enemy Hit | Boss Death |
| :------------: |:------------: |:------------: |
| ![hitstun](https://github.com/user-attachments/assets/87f6a16c-21a3-43d1-b8cd-4cd9850c529c) | ![enemy_hit](https://github.com/user-attachments/assets/1fdc4221-895e-47e0-98d6-c7850692a539) | ![boss_death](https://github.com/user-attachments/assets/d3687108-06c2-4db5-babc-a58569d7ff76) |

### Game Balance

The first aspect of balance was player level balance. Basically, what I wanted was to have the player have a need to farm early levels and slowly move up in power as they traverse. I decided to go with a exponential leveling curve. The first reason is because it gives the player a reason to stay in the earlier regions to farm for their first upgrade. The second reason is because it makes the farming experience less dull because once you get the dopamine hit of getting that first upgrade, you will be constantly getting new different weapons which is extremely satisfying. The spawners and enemy types were placed around the map to support the exponential leveling curve.

The 2nd aspect of balance was boss balance. Initially, I went with balancing the boss around unlocking your 3rd-4th weapon and if I could personally beat the boss. However after looking at playtests and also the Final Festival, I found that I probably made it way too hard because I already had a lot of practice beating this game. Due to this, I made the boss have less hp and increased some damage of a few weapons. This makes killing the boss less daunting plus the boss already is difficult enough with it placing fire traps and the swarms of enemies that you have to deal with.

### Visual Clutter Balance

There were a few things I did in order to reduce visual clutter. The first was cleaning up the center of the map path and adding an obvious border. During the final festival and game feedback we got, we found that players would get pretty lost and also get ambushed by enemies hiding in trees or bushes, which is not fun at all. I removed a lot of decoration from the center of the path and to make the path to the boss clearer, I added a tree border that indicates that you are going on a path. The second thing was zoom out the camera a bit. We noticed that even if players would go on the right path, they sometimes would backtrack because they think they are in the middle of the map at times. By zooming out the camera, it is a lot easier to see the path border from the center of the path.

## Narrative Design - Charlie Edwards

I utlized the Godot plugin Dialogue Manager to assist with creating dialogue and to have the option for branching dialogue trees. [Source](https://github.com/nathanhoad/godot_dialogue_manager/tree/main), [License](https://github.com/nathanhoad/godot_dialogue_manager/blob/main/LICENSE)

Dialogue Manager lets me manage all of the game's dialogue in a single text file, where I can sequentially call dialogue and functions. Once implemented, it gave me a simple, systematic way of implementing new dialogue with the option for branching dialogue. This is done by creating an Actionable node that has a CollisionShape2D as a child. I found this [general tutorial](https://www.youtube.com/watch?v=UhPFk8FSbd8) and this [cutscene tutorial](https://www.youtube.com/watch?v=G_TN8jz4v9o) by the creator of the plugin very useful. Since we do not have any voice acting, I used pictures in the dialogue box to show who is talking.

![dialogue1](https://github.com/user-attachments/assets/7be66754-a455-4856-927c-43ce2c6433d3)

The player is allowed to move during dialogue because some signs, containing dialogue, are placed where enemies may be present; so we decided it was best to always let the player move during dialogue. 

The introduction cutscene gives the context of the game and makes it clear early on that this is a light-hearted game, not meant to be taken too seriously. The death of the dog, Lucky, establishes the motivation of the Necromancer's rampage and shows how despicably evil the boss is. We wanted something early on in the story to grab the player's attention and utlize most people's love for animals as motivation to complete the game, reuniting the Necromancer and Lucky. 

I also chose to put an interactable sign right after the first cutscene, at the start of the gameplay, to build ituition in the player to interact with any futures signs they see as interacting with a sign is necessary in order to start the boss fight later.

<img width="400" alt="first sign1" src="https://github.com/user-attachments/assets/a1c6e126-10e5-4bf6-9b75-715a8b82cb1d" />


This first sign just has a simple beware of enemies message that serves to warn the player of future enemies, but mainly is there to make the player want to interact with signs. The second sign is found right before the boss fight and while disguised as just another warning sign, starts the boss fight.

## Audio - Jason Gao

For the audio, I made a scene that contains all of the audio used and set it as auto load, that way the audio can be accessed anywhere throughout the scripts. For most of the audio I found online, I had edited it in Audacity to fit the run time and how it fits with the gameplay. The sound style is made with a bit of realism, where the sound changes depending on what terrain type you are on. This is implemented by creating custom data in the tile map, where the water tiles and ground tiles are identified as different integers. There are sfx where the enemy and player shoots, also when they get hit, making it more engaging and interactive.

Death:https://pixabay.com/sound-effects/bone-break-sound-269658/

Walk_Grass:https://pixabay.com/sound-effects/rustling-grass-4-101281/

Walk_Water:https://www.soundeffectsplus.com/product/footsteps-walking-in-water-slow-01/

Sprout_Attack:https://uppbeat.io/sfx/magic-spell-sparkle-blast/8696/22666

Player_Projectile:https://uppbeat.io/sfx/futuristic-gun-pulse-blaster/4931/19131

Chicken_Attack:https://pixabay.com/es/sound-effects/chicken-noise-228106/

## Gameplay Testing - Cyrus Azad

https://docs.google.com/spreadsheets/d/1X2j1hcNl1cKqkbSP1UwaEB2jO-dW82fZK-mUiMTT_Zk/edit?gid=616130533#gid=616130533 

Here are the results of the gameplay tests. I chose 10 of the given questions to ask each tester, and these questions were:

1) What was your favorite part about the game?
2) What didn't you like about the game? 
3) What was confusing? 
4) Was the objective clear at all times?
5) What elements do you think could be improved?
6) Was the game’s premise appealing to you?
7) Were the procedures and rules easy to understand?
8) Could you ﬁnd the information you needed on the interface?
9) What was missing from the game?
10) Who do you think is the target audience for this game?
11) If you were to suggest that one change be made to the game, what would it be?


Throughout the tests it became clear that the flaws that we did have in our game were a bit troublesome. One of the main flaws was the map, as we did not make a direct path within the map for the player to follow. This led to some of the players walking around aimlessly for a while before I told them where they needed to go. Upon learning this, we made the map much more intuitive with the trees working as a wall guide. There is also a sign at the end that you need to interact with in order to trigger the boss battle. Many of the players did not know what that sign did or that they had to interact with the sign in order to get to the boss battle. 

Some of the other issues mentioned included:
- Grammatical mistakes in dialogue
- Balancing the enemies/boss abilities
- Cooldown timers were too small to read
- There weren’t indicators for when the player unlocks a new ability

We also had a lot of positive feedback from these testers as well, commonly including:
- The controls were simple and easy to use 
- The game was challenging, which made it more fun
- The testers enjoyed the art style we used
- Most of the testers enjoyed the premise of the game

It was also very interesting to see the different feedback between testers who played games a lot and those who did not. Watching these testers was quite fun, as the panic and frustration of the players who had not played many roguelike games before was entertaining, whereas the experienced players were more curious about each of the mechanics and specifics rather than just surviving. Many of the testers who played a lot of games focused on critiquing specific gameplay mechanics or aspects of the game, whereas people who did not play as much focused on quality of life changes that would make the game more fun for themselves personally. 

Some of the aspects we could improve further would be:
- Make an easier mode for players who are less experienced so they can enjoy the game more
- Make more dialogue points so that the player is guided much easier
- Make a pause and restart feature
- Make a information page that goes over the player and enemy abilities 
- Expand the map more and make more miniature objectives on the way to the boss

