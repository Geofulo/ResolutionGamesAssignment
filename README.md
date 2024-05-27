# Resolution Games Assignment
This AR application is my solution to an assignment from Resolution Games.

### Technical description
The application uses **ARKit** to manage the AR session and detect planes using `ARPlaneAnchor`.
It employs **RealityKit** to load and manage entities (`Entity`).

The application loads .usdc files asynchronously.
User taps on the cubes are recognized using a `UITapGestureRecognizer`.
The cube moves forward in the direction the camera is facing.
