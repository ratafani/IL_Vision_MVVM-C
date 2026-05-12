# ILVision: Enterprise Flight Simulation Framework for visionOS

ILVision is a high-performance framework for building immersive training and simulation applications on Apple Vision Pro. It demonstrates a robust **MVVM-C-ECS** architecture that bridges professional 2D interface management with high-frequency 3D simulation logic.

---

## Why This Architecture?

Developing for visionOS presents a unique challenge: managing traditional 2D SwiftUI windows alongside a 90FPS RealityKit rendering loop. This project solves that by enforcing strict boundaries:

*   **Modular Compilation**: By using 7 local Swift Packages, only the modified parts of the app are recompiled, drastically reducing development iteration time.
*   **Decoupled Rendering**: The 3D Simulation (ECS) is decoupled from the UI (SwiftUI). You can update the cockpit layout without touching the flight physics, and vice-versa.
*   **Hardware Abstraction**: Low-level sensors (ARKit Hand Tracking) are isolated, allowing the core simulation logic to remain pure and testable.
*   **Asset Safety**: 3D content is managed in a dedicated package, ensuring that binary asset updates do not interfere with source code stability.

---

## Module Architecture

The project is structured into specialized local packages, each with a single responsibility:

| Package | Role | Why it helps |
| :--- | :--- | :--- |
| **`ILVisionDomain`** | Core Logic | Contains pure Swift models and protocols. The "Single Source of Truth." |
| **`ILVisionData`** | Persistence | Handles SharePlay networking, API clients, and local storage. |
| **`ILVisionAssets`** | 3D Content | Dedicated Reality Composer Pro bundle. Keeps binary assets isolated from code. |
| **`ILVisionHandTracking`** | Hardware | Wraps ARKit Skeletal Hand Tracking into reusable RealityKit Systems. |
| **`ILVisionSimulation`** | 3D Engine | RealityKit ECS Systems (Movement, Interaction, Collision). |
| **`ILVisionUI`** | Presentation | SwiftUI Views, ViewModels, and AppCoordinators for window management. |
| **`ILVisionCore`** | Injection | The Dependency Injection hub that wires all modules together. |

---

## Developer Workflow

### 1. Adding a New Feature
To add a new feature (e.g., "Engine Startup Training"):
1.  **Define the Interface**: Add a new protocol in `ILVisionDomain`.
2.  **Implement Data**: Add a repository in `ILVisionData` to handle state persistence.
3.  **Create the Simulation**: Add ECS Components and Systems in `ILVisionSimulation` to handle 3D interaction.
4.  **Build the UI**: Add a feature folder in `ILVisionUI` for the SwiftUI panels and ViewModels.
5.  **Inject**: Register the new services in `ILVisionCore`.

### 2. Managing 3D Assets
All 3D models and RealityKit scenes live in **`ILVisionAssets`**. 
*   Open the `RealityContent.rkassets` folder in Reality Composer Pro to add new cockpit parts or environment models.
*   Reference these assets in `ILVisionSimulation` using the `ILVisionAssets.bundle` identifier.

### 3. Communicating Between UI and 3D
The app uses a **Bridge Pattern** to sync states:
*   **UI → Simulation**: The SwiftUI ViewModels update the `AppModel`, which is read by ECS Systems via the `AppModelServiceComponent`.
*   **Simulation → UI**: ECS Systems publish events or update shared repositories that the SwiftUI layer observes.

---

## Technical Specifications

*   **Platform**: visionOS 2.0+ (v26.0)
*   **Rendering**: RealityKit (ECS)
*   **Interaction**: ARKit (Hand Tracking)
*   **Collaboration**: GroupActivities (SharePlay)
*   **Patterns**: MVVM-C (Model-View-ViewModel-Coordinator), Clean Architecture, Dependency Injection.
