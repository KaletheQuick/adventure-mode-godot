# adventure-mode-godot
Adventure Mode is a 3D third person template for the Godot engine that combines the basic movement and exploration mechanics, and base combat experience of a wide variety of games:
- The Legend of Zelda: Breath of the Wild
- The Legend of Zelda: Tears of the Kingdom
- Dark Souls 1,2,3
- Not Bloodborne, I hate Bloodborne. Just go play Devil May Cry
- Elden Ring


## Key Features
- Moving and jumping around 3D space in a variety of modes, walking, running, jumping, climbing, swimming, flying. 
- Basic combat, melee and ranged attacks determined by data (such as equipped weapons or stats).
- Item management. Using items such as potions. Consumable and reusable. 
- Multiplayer.

Some features are often overwritten or retooled per end developer needs. So this project explicitly does not include, or include intended publishing ready quality:
- Inventory management systems.
- Character building (stats and leveling up) systems.
- Terrain generation (voxels, heightmaps)
- Graphics.
- Netcode. 

## Goals
- Basic walking/running movement
- Ability to extend to further movement modes such as parkour, climbing, swimming, flying
- Basic combat

## Cool cams / stretch goals
- Multiplayer progression system like the souls games kinda do with covenants, or just simply a more fleshed out leveling/progression system that motivates the player. 
- Rewarding the player based on more efficient use of mechanics. Essentially saying, the user completing a more smooth and continuous combo would be rewarded with more damage, or possibly even loot/rewards for beating the mob.
- Dress up system. UI or code interface to combine skeletal skinned meshes and modify their materials into a single unified mesh could be reused in numerous projects. 

## Multiplayer Information
Though multiplayer, only a basic implementation is to be provided. It is common to replace and implement more advanced or specific systems. Like matchmaking, lag compensation, etc. So while data and the structures are set up to be synced through the network; like positions, item use, animation state, character customization (an example thereof), the network code isn't meant to be a perfectly scaleable one size fits all solution.
