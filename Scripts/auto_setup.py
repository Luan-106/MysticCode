"""
GLITCH//SHIFT: DON'T LOOK BACK - Unreal Editor Python Setup Script
MysticCode Game Jam Project

HOW TO RUN:
1. Open the project in Unreal Engine 5.8
2. Go to: Edit > Preferences > General > Source Code > Auto-run Python scripts
   OR: Go to Tools > Execute Python Script...
3. Select and run this script file.

This script auto-creates Blueprint classes and content folder structure.
Run once. Safe to re-run (checks for existence before creating).
"""

import unreal
import os

# ============================================================
# FOLDER STRUCTURE
# ============================================================

FOLDERS_TO_CREATE = [
    "/Game/Blueprints",
    "/Game/Blueprints/Core",
    "/Game/Blueprints/Interactables",
    "/Game/Blueprints/AI",
    "/Game/Blueprints/UI",
    "/Game/Maps",
    "/Game/Input",
    "/Game/Audio",
    "/Game/Materials",
    "/Game/DataAssets",
]

def create_folders():
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    for folder in FOLDERS_TO_CREATE:
        if not unreal.EditorAssetLibrary.does_directory_exist(folder):
            unreal.EditorAssetLibrary.make_directory(folder)
            unreal.log(f"Created folder: {folder}")
        else:
            unreal.log(f"Folder already exists: {folder}")

# ============================================================
# BLUEPRINT CREATION HELPERS
# ============================================================

def create_blueprint(package_path: str, asset_name: str, parent_class) -> unreal.Blueprint:
    """Create a Blueprint class if it doesn't exist. Returns the blueprint object."""
    full_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(full_path):
        unreal.log(f"Blueprint already exists: {full_path}")
        return unreal.EditorAssetLibrary.load_asset(full_path)
    
    factory = unreal.BlueprintFactory()
    factory.set_editor_property("parent_class", parent_class)
    
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    blueprint = asset_tools.create_asset(asset_name, package_path, unreal.Blueprint, factory)
    
    if blueprint:
        unreal.EditorAssetLibrary.save_asset(full_path)
        unreal.log(f"Created Blueprint: {full_path}")
    else:
        unreal.log_warning(f"Failed to create Blueprint: {full_path}")
    
    return blueprint


def create_interface(package_path: str, asset_name: str) -> unreal.Blueprint:
    """Create a Blueprint Interface if it doesn't exist."""
    full_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(full_path):
        unreal.log(f"Interface already exists: {full_path}")
        return unreal.EditorAssetLibrary.load_asset(full_path)
    
    factory = unreal.BlueprintInterfaceFactory()
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    interface = asset_tools.create_asset(asset_name, package_path, unreal.Blueprint, factory)
    
    if interface:
        unreal.EditorAssetLibrary.save_asset(full_path)
        unreal.log(f"Created Interface: {full_path}")
    else:
        unreal.log_warning(f"Failed to create Interface: {full_path}")
    
    return interface


def create_widget_blueprint(package_path: str, asset_name: str) -> unreal.Blueprint:
    """Create a UMG Widget Blueprint if it doesn't exist."""
    full_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(full_path):
        unreal.log(f"Widget already exists: {full_path}")
        return unreal.EditorAssetLibrary.load_asset(full_path)
    
    factory = unreal.WidgetBlueprintFactory()
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    widget = asset_tools.create_asset(asset_name, package_path, unreal.WidgetBlueprint, factory)
    
    if widget:
        unreal.EditorAssetLibrary.save_asset(full_path)
        unreal.log(f"Created Widget Blueprint: {full_path}")
    else:
        unreal.log_warning(f"Failed to create Widget: {full_path}")
    
    return widget


def create_input_action(package_path: str, asset_name: str, value_type) -> object:
    """Create an Enhanced Input Action asset."""
    full_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(full_path):
        unreal.log(f"Input Action already exists: {full_path}")
        return unreal.EditorAssetLibrary.load_asset(full_path)
    
    factory = unreal.InputActionFactory()
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    action = asset_tools.create_asset(asset_name, package_path, unreal.InputAction, factory)
    
    if action:
        action.set_editor_property("value_type", value_type)
        unreal.EditorAssetLibrary.save_asset(full_path)
        unreal.log(f"Created Input Action: {full_path}")
    
    return action


def create_input_mapping_context(package_path: str, asset_name: str) -> object:
    """Create an Enhanced Input Mapping Context asset."""
    full_path = f"{package_path}/{asset_name}"
    
    if unreal.EditorAssetLibrary.does_asset_exist(full_path):
        unreal.log(f"IMC already exists: {full_path}")
        return unreal.EditorAssetLibrary.load_asset(full_path)
    
    factory = unreal.InputMappingContextFactory()
    asset_tools = unreal.AssetToolsHelpers.get_asset_tools()
    imc = asset_tools.create_asset(asset_name, package_path, unreal.InputMappingContext, factory)
    
    if imc:
        unreal.EditorAssetLibrary.save_asset(full_path)
        unreal.log(f"Created IMC: {full_path}")
    
    return imc


# ============================================================
# MAIN: CREATE ALL ASSETS
# ============================================================

def main():
    unreal.log("=" * 60)
    unreal.log("GLITCH//SHIFT: DON'T LOOK BACK - Auto Setup")
    unreal.log("MysticCode | Unreal Engine 5.8")
    unreal.log("=" * 60)

    # Step 1: Create folders
    unreal.log("\n--- Creating Folder Structure ---")
    create_folders()

    # Step 2: Create Blueprint Interface
    unreal.log("\n--- Creating Blueprint Interface ---")
    create_interface("/Game/Blueprints/Core", "BPI_Interactable")

    # Step 3: Create Core Game Blueprints
    unreal.log("\n--- Creating Core Game Blueprints ---")
    
    # GameMode
    create_blueprint("/Game/Blueprints/Core", "BP_GameMode", unreal.GameModeBase)
    
    # Player Character (based on Character, not Pawn, for built-in movement)
    create_blueprint("/Game/Blueprints/Core", "BP_PlayerCharacter", unreal.Character)
    
    # Player Controller
    create_blueprint("/Game/Blueprints/Core", "BP_PlayerController", unreal.PlayerController)
    
    # Objective Manager (Actor)
    create_blueprint("/Game/Blueprints/Core", "BP_ObjectiveManager", unreal.Actor)
    
    # Reality Manager (Actor)
    create_blueprint("/Game/Blueprints/Core", "BP_RealityManager", unreal.Actor)
    
    # Checkpoint Actor
    create_blueprint("/Game/Blueprints/Core", "BP_Checkpoint", unreal.Actor)

    # Step 4: Create Interactable Blueprints
    unreal.log("\n--- Creating Interactable Blueprints ---")
    create_blueprint("/Game/Blueprints/Interactables", "BP_Door", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_Keycard", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_PowerRelay", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_Keypad", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_Note", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_ExitElevator", unreal.Actor)
    create_blueprint("/Game/Blueprints/Interactables", "BP_RealityPairedActor", unreal.Actor)

    # Step 5: Create AI Blueprints
    unreal.log("\n--- Creating AI Blueprints ---")
    create_blueprint("/Game/Blueprints/AI", "BP_Subject0", unreal.Character)
    create_blueprint("/Game/Blueprints/AI", "BP_Subject0_AIController", unreal.AIController)
    create_blueprint("/Game/Blueprints/AI", "BP_PatrolPoint", unreal.Actor)

    # Step 6: Create UI Widgets
    unreal.log("\n--- Creating UI Widget Blueprints ---")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_MainMenu")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_GameHUD")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_PauseMenu")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_DeathScreen")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_VictoryScreen")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_InteractionPrompt")
    create_widget_blueprint("/Game/Blueprints/UI", "WBP_KeypadInput")

    # Step 7: Create Enhanced Input Actions
    unreal.log("\n--- Creating Enhanced Input Actions ---")
    ia_move = create_input_action("/Game/Input", "IA_Move", unreal.InputActionValueType.AXIS2D)
    ia_look = create_input_action("/Game/Input", "IA_Look", unreal.InputActionValueType.AXIS2D)
    ia_sprint = create_input_action("/Game/Input", "IA_Sprint", unreal.InputActionValueType.BOOLEAN)
    ia_interact = create_input_action("/Game/Input", "IA_Interact", unreal.InputActionValueType.BOOLEAN)
    ia_flashlight = create_input_action("/Game/Input", "IA_Flashlight", unreal.InputActionValueType.BOOLEAN)
    ia_reality_shift = create_input_action("/Game/Input", "IA_RealityShift", unreal.InputActionValueType.BOOLEAN)
    ia_crouch = create_input_action("/Game/Input", "IA_Crouch", unreal.InputActionValueType.BOOLEAN)
    ia_jump = create_input_action("/Game/Input", "IA_Jump", unreal.InputActionValueType.BOOLEAN)
    ia_menu = create_input_action("/Game/Input", "IA_Menu", unreal.InputActionValueType.BOOLEAN)

    # Step 8: Create Input Mapping Context
    unreal.log("\n--- Creating Input Mapping Context ---")
    imc = create_input_mapping_context("/Game/Input", "IMC_MysticCode")

    unreal.log("\n" + "=" * 60)
    unreal.log("SETUP COMPLETE!")
    unreal.log("All Blueprint stubs and Input Actions created.")
    unreal.log("")
    unreal.log("NEXT STEPS (Manual in Unreal Editor):")
    unreal.log("1. Open BP_PlayerCharacter -> Add: Camera, SpringArm,")
    unreal.log("   SpotLight (Flashlight), InputComponent")
    unreal.log("2. Set BP_GameMode's Default Pawn Class = BP_PlayerCharacter")
    unreal.log("3. Set BP_GameMode's HUD Class = WBP_GameHUD")
    unreal.log("4. Open IMC_MysticCode and bind IA_Move to WASD,") 
    unreal.log("   IA_Look to Mouse XY, etc.")
    unreal.log("5. Create FacilityMap and MainMenu maps in /Game/Maps/")
    unreal.log("6. Run NavMesh build in the level editor (Build > Build Navigation)")
    unreal.log("See MANUAL_SETUP.md for complete step-by-step instructions.")
    unreal.log("=" * 60)


# Run
if __name__ == "__main__":
    main()
else:
    main()
