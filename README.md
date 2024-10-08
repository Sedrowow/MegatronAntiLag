# Megatron Anti-Lag (MAL)

A Stormworks script designed to manage and reduce lag caused by vehicles in multiplayer servers.

## What does it do exactly?

Megatron Anti-Lag (MAL) monitors vehicles spawned in the game, calculates a "lag cost" based on the components each vehicle contains, and despawns vehicles or vehicle groups when they exceed predefined limits. The script associates vehicles with the players who spawned them, ensuring that individual players cannot negatively impact server performance by spawning excessively lag-inducing vehicles.

**Key Features:**

- **Component-Based Lag Calculation:** Calculates lag cost based on the actual components of vehicles rather than just voxel count.
- **Per-Player Lag Monitoring:** Tracks the lag cost per player (`peer_id`) to manage individual impact on server performance.
- **Automatic Despawning:** Automatically despawns vehicles or groups when a player's total lag cost exceeds the set limit.
- **Customizable Settings:** Allows server administrators to adjust lag cost limits and component weights to suit their server's needs.
- **Real-Time Performance Management:** Monitors game performance and adjusts accordingly to maintain optimal TPS (Ticks Per Second).

## Why was it made?

**Reasons:**

- **Other Antilags Block Workbench:** Existing Antilag scripts often restrict access to the workbench, limiting player creativity and freedom.
- **Inaccurate Lag Calculations:** Many scripts calculate lag based solely on voxel count, which doesn't accurately represent the performance impact of different components.
- **Outdated Solutions:** Current available scripts are outdated and may not utilize the latest features of the Stormworks Lua API, leading to inefficiencies.

## Why make it publicly available?

Most well-made scripts are not publicly shared, restricting their benefits to a limited number of servers. By making Megatron Anti-Lag publicly available, we aim to:

- **Enhance Server Performance:** Provide a high-quality Antilag solution accessible to all servers.
- **Encourage Customization:** Allow each server to tailor the script to their own needs, promoting a personalized gaming experience.
- **Foster Community Collaboration:** Enable the community to share improvements and collectively develop one of the best Antilag scripts ever created.

---

Feel free to contribute to the project or customize it to better suit your server's requirements. Together, we can improve gameplay performance and enjoyment for everyone in the Stormworks community.
