1. Add to resources folder
2. Add to server.cfg
3. Set your server default spawn to: vector3(-2950.404, -1947.5, 882.56) or vector4(-2950.404, -1947.5, 882.56, 69.0)

Notes:
Plane is a cargo plane vehicle, engines on and doors set to open, it spawns and is frozen, this allows the player to spawn in and jump out. The main issue with the current setup is that it doesn't use routing buckets to stop players seeing the plane/effects from the ground, I may fix this later on but right now I have not much knowledge in this area. If you change the plane location, you will need to re-do all of the polyzone and the particle effects location. I made this for my survival server so it's fairly basic. I may add XYZ offsets based on the plane location and do a proper config, but for now it's all in the client.lua

