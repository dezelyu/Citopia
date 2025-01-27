![](Assets/Logo.gif)
#
### Overview
Citopia is a high-performance crowd simulation project featuring detailed daily routines of diverse NPCs in a modern city environment. This project was developed in Swift using the Metal API by Deze Lyu, Paulina Tao, and Christine Kneer.


https://github.com/user-attachments/assets/d725e7dc-ea8f-438a-b667-4b0af6554cbd


#
### License
This project is licensed under the Creative Commons Attribution-NonCommercial 4.0 International License, allowing for sharing and adaptation with appropriate credit given to the authors and for non-commercial purposes. The project also includes an experimental game engine developed by Deze Lyu, located in the Libraries folder. This engine remains in development and is not intended for external use. Additionally, third-party assets purchased from online asset stores have been used to visualize the simulation results. These assets have been extensively modified, and their usage fully complies with the respective licenses.
#
### Milestones
For Milestone 1, we implemented a simulation of 100,000 characters on a flat plane, with characters of different genders either standing still or walking in random directions at varying intervals. Our system efficiently selects visible characters within the camera frustum, sorts them by distance, and renders between 400 and 1,000 characters closest to the camera, adapting to platform capabilities such as mobile and desktop. The characters move and rotate smoothly, achieving responsive, real-time performance. We also developed an acceleration structure that organizes characters in a grid based on their current positions, although it has yet to be fully utilized. Additionally, we encountered an issue with abrupt transitions between idle and walking animations in the custom game engine’s animation system, which we plan to address in future milestones.
![](Assets/Milestone1.gif)
For Milestone 2, we established the foundation of a large-scale cyberpunk city with 10,000 procedurally generated buildings, including apartment complexes and office spaces, each featuring detailed interiors. A connected network of map nodes was implemented to facilitate character navigation. We introduced a basic daily routine for 100,000 characters, encompassing three key behaviors: working, wandering the streets, and sleeping. Characters travel to designated office spots when their daily earnings fall short of expectations, wander the streets until their energy is depleted, and return to assigned apartment spots to sleep and recharge for the next day. Additionally, we implemented rigid body collision for characters within a specific range of the camera, ensuring they do not pass through one another. Significant enhancements were also made to the motion control system, rendering pipeline, simulation optimizations, and overall code structure, improving both functionality and performance.
![](Assets/Milestone2.gif)
For Milestone 3, we implemented character-to-character interactions, introducing a new layer of social dynamics. Each character now has a unique personality, represented as a three-component vector that determines their visual color. Characters engage in social interactions after completing their daily work and when they have sufficient energy. When two characters with similar personalities, calculated through the dot product of their personality vectors, meet, they initiate communication and play a rapping animation, during which their personalities gradually converge, resulting in more similar colors. We also added distinct walking motions to reflect characters’ current states, such as heading to work, feeling relaxed, or showing fatigue. Additionally, we began developing entertainment buildings like gyms and libraries, though these are not yet integrated due to ongoing optimization challenges. Significant progress was made in optimizing simulation kernels, reducing compute times to under 8 milliseconds by splitting the kernel into smaller, more efficient units and utilizing dispatch indirect to minimize the overall thread count.
![](Assets/Milestone3.gif)
For the final version, we completed the integration of entertainment building types, finalizing the foundation for gyms, libraries, and introducing additional buildings such as restaurants, bars, and redemption centers. Characters now dynamically search for available spots in these buildings, with behavior tailored to the type of venue, differentiating them from the static routines seen at offices and apartment complexes. We also introduced a disturbance system, with zombie attacks affecting the default behavior of characters. When under threat, characters exhibit panic responses, fleeing from danger, adding a layer of unpredictability and realism to the simulation. In addition, further optimization efforts reduced simulation load, ensuring smooth performance even with the increased complexity of interactions and behaviors. With these enhancements, the system now supports a dynamic, interactive world where characters react to both their environment and each other in a variety of ways, providing a rich, immersive experience.
![](Assets/Milestone4.gif)
#
### Setup Instructions
To build and run this project, use Xcode version 15.4 or later. Open the Xcode project file located in the Sources folder, and ensure an appropriate development team is selected in the Signing & Capabilities settings to enable local execution. If you encounter an error related to AVKit, you may need to remove and re-add the AVKit framework under “Link Binary with Libraries” in the Build Phases settings.
#
### Control Instructions
To begin the simulation, press the **P** key. Once started, you can use the following controls:
- **Mouse**: Rotate the camera.
- **W**: Move along the camera's forward direction.
- **A**: Move along the camera's left direction.
- **S**: Move along the camera's backward direction.
- **D**: Move along the camera's right direction.
- **Space**: Increase movement speed.
- **V**: Toggle the visibility of ceilings.
- **Z**: Zombify the group of characters pointed at by the cursor.
