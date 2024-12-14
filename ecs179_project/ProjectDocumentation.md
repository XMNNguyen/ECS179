# Necromancer Roguelike #

## Summary ##

## Resources

## Gameplay Explanation ##

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

## Game Logic - Martin Nguyen

Note: Even though this was my main role, there were some aspects of game logic that everyone worked on together.

### Enemy Logic
|Chicken |Sprout |Troll |
| :------------: |:------------: |:------------: |
|![chicken](https://github.com/user-attachments/assets/61ed009e-23bf-4eff-a5c4-31103b173a42) | ![sprout](https://github.com/user-attachments/assets/2d62c025-7d75-483f-beaf-e85b4605751a) |![troll](https://github.com/user-attachments/assets/24ca2a58-6db2-4ff6-8de5-6eb6a6b337b8)|

### Weapon Logic

|Standard |Shotgun |Wave |Scatter |Chain | 
| :------------: |:------------: |:------------: | :------------: | :------------: |
| ![standard_bullet](https://github.com/user-attachments/assets/36c567e6-743e-4093-88ee-e0d4e856ee22) | ![shotgun_bullet](https://github.com/user-attachments/assets/db9f5ff7-ced1-40fc-922b-23f8d040d17c)| ![wave_bullet](https://github.com/user-attachments/assets/92ff47cf-2382-41cc-8d83-414164e14e16) | ![scatter_bullet](https://github.com/user-attachments/assets/5cc0c743-3d08-4a34-b9f9-a4e60f6da317) | ![chain_bullet](https://github.com/user-attachments/assets/ad2ee42a-adb6-4794-acd0-2e0ae1f0fdb7) |

### Isometric Tile Logic

| Before | After |
| :------------: |:------------: |
| ![tile_map_1](https://github.com/user-attachments/assets/ebb86ace-66bd-4edd-944e-4e1f46f6a282) | ![tile_map_3](https://github.com/user-attachments/assets/44cb1e3d-f1b2-44d8-9140-c6730f55077d) | 

### Leveling Logic



## Animation and Visuals - Charlie Edwards

## User Interface and Input - Jason Gao

## Movement - Physics - Cyrus Azad
Note: Even though this was my main role, there were aspects that everyone worked together on. 

The movement and physics in our game are very simple. The player is given 8 directional movement using the WASD keyboard keys, using the standard Godot movement systems of velocity and move_and_slide() in order to implement this. We had to make functions for the player to be able to move over a slope smoothly, which was done by finding the tile data and adding a movement bias based on the input direction of the player and the type of slope they were on. We also added a helper function adjust_z_index to help keep the player walking on the surface instead of walking through the slopes and disappearing. 

The enemy movement was implemented the same way, except instead of inputting directions the enemies locked on to and followed the player once the player was in range. We used vectors in order to calculate the direction of the player in reference to the given enemy so that the enemy knew which direction to move and/or attack. We also implemented different attacks for each enemy. Every time the player gets hit by an enemy attack, there is a stunlock where the movement of all enemies and players pauses, and there is an audio queue and camera shake in order to signify to the player that they took damage. The chicken starts a wind up timer once in attack range, and then launches it’s body at the player’s current position as a charge peck attack towards the player at a very increased velocity. The sprout fires a projectile at a given bullet_velocity in the direction of the player. For the troll, we made their attack very similar to the chicken with a wind up and charge, however when the troll hits the player it grabs them, stunning the player for a time given by the stun_timer. We made a signal to show the player that they are stunned and made the player have to be idle until the stun_timer is over. The boss attack is the same as the sprout’s in its movement and physics, but with different animation and stronger stats. 

We also implemented different attacks with different physics mechanics. The base standard bullet simply fires a projectile at the nearest enemy. The shotgun weapon finds the nearest enemy, and then converts a given shotgun angle into radians, with the center of the angle being the location of the nearest enemy. It then divides the angle into different sections based on how many shotgun bullets there are, and fires the bullets in a spread shot within the angle given. The wave bullet is more of a pulse, as it uses vectors to send a short range wave of energy in each diagonal direction of the player, not accounting for enemy position at all. The chain bullet was very interesting to implement, as it shoots a bullet at the nearest enemy similar to the standard bullet, but then once an enemy is hit, it uses the enemy’s global position to find the next nearest enemy, and calculates if it is within a range of bounce_distance. If the enemy is within the range, the bullet then bounces and hits that next enemy, and then repeats for a given number of bounces. 


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

### Hit Satisfaction

| Player Hitstun | Enemy Hit | Boss Death |
| :------------: |:------------: |:------------: |
| ![hitstun](https://github.com/user-attachments/assets/87f6a16c-21a3-43d1-b8cd-4cd9850c529c) | ![enemy_hit](https://github.com/user-attachments/assets/1fdc4221-895e-47e0-98d6-c7850692a539) | ![boss_death](https://github.com/user-attachments/assets/d3687108-06c2-4db5-babc-a58569d7ff76) |

### Game Balance

### Visual Clutter Balance

## Narrative Design - Charlie Edwards

## Audio - Jason Gao

## Gameplay Testing - Cyrus Azad
