namespace MultiRightPlay {
    string origML;
    bool gotOrigML = false;

    void OnPluginLoad() {
        CGameUILayer@ l;
        while ((@l = GetMenuSceneLayer()) is null) {
            sleep(200);
        }
        origML = l.ManialinkPageUtf8;
        gotOrigML = true;
        while (!IsReady()) sleep(100);
        while (GetMenuSceneLayer() is null) sleep(100);
        ApplyMenuBg();
    }

    bool _UpdateMenuPositions = false;
    void OnPlaygroundMLExec(ref@ _meh) {
        if (!_UpdateMenuPositions) return;
        _UpdateMenuPositions = false;
    }

    bool IsReady() {
        print("Trying to load ML...");
        return origML.Length > 0;
    }

    bool _MenuItemExists = false;
    bool MenuItemExists() {
        if (_MenuItemExists) return true;
        return _MenuItemExists;
    }

    bool ApplyMenuBg() {
        if (!IsReady()) return false;
        if (applied) return true;
        auto l = GetMenuSceneLayer(false);
        if (l is null) return false;
        if (!l.ManialinkPageUtf8.Contains("button-quickswitch-multiplayer")) {
            auto patch = GetMenuPatches2();
            l.ManialinkPageUtf8 = patch.Apply(origML);
        } else {
            gotOrigML = false;
        }
        applied = true;
        return true;
    }

    CGameUILayer@ GetMenuSceneLayer(bool canYield = true) {
        auto app = cast<CTrackMania>(GetApp());
        while (app.MenuManager is null) {
            if (!canYield) return null;
            yield();
        }
        auto mm = app.MenuManager;
        while (mm.MenuCustom_CurrentManiaApp is null) {
            if (!canYield) return null;
            yield();
        }
        auto mca = mm.MenuCustom_CurrentManiaApp;
        while (mca.UILayers.Length < 30) yield();
        for (uint i = 0; i < mca.UILayers.Length; i++) {
            auto l = mca.UILayers[i];
            if (l is null) continue;
            if (IsLayerMainMenuBg(l)) {
                return l;
            }
        }
        return null;
    }

    bool IsLayerMainMenuBg(CGameUILayer@ l) {
        return(l.ManialinkPageUtf8.Contains('<manialink name="Page_HomePage" version="3">'));
    }

    bool applied = false;
}

APatchSet@ GetMenuPatches2() {
    APatchSet@ patches = APatchSet();

    patches.AddPatch(AppendPatch("""<frameinstance
		id="button-play"
		modelid="component-cmgame-expendable-button"
		class="component-navigation-item"
		pos="-82.5943 42."
		z-index="1"
		data-text="|HomePage|Play"
		data-supersample="1"
		data-styles="component-trackmania-expendable-button-style-stack component-trackmania-expendable-button-style-stack-top expendable-button-style-stack-homepage"

		data-nav-inputs="select;cancel;up;down;right;left"
		data-nav-targets="_;_;button-settings;button-clubs;_;_"
		data-nav-group="navgroup-home-page"
		data-nav-zone="CMGame_ExpendableButton_quad-nav-zone"
	/>""", """
    <frameinstance
		id="button-quickswitch-multiplayer"
		modelid="component-cmgame-expendable-button"
		class="component-navigation-item"
		pos="-42.25 48"
		z-index="1"
		data-text=""
		data-supersample="1"
		data-styles="component-trackmania-expendable-button-style-stack component-trackmania-expendable-button-style-stack-bottom"

		data-nav-inputs="select;cancel;up;down;right;left"
		data-nav-targets="_;_;button-play;button-clubs;_;_"
		data-nav-group="navgroup-home-page"
		data-nav-zone="CMGame_ExpendableButton_quad-nav-zone"
	/>"""));
    patches.AddPatch(AppendPatch("""case "button-settings": {
			Router_Router::SetParentPath(This, "/settings", "/home");
			Router_Router::Push(This, "/settings");
		}""", """case "button-quickswitch-multiplayer": {
            Router_Router::SetParentPath(This, "/live/arcade", "/home");
			Router_Router::Push(This, "/live/arcade");
		}"""));
    patches.AddPatch(AppendPatch("""Button_Play = (Frame_Global.GetFirstChild("button-play") as CMlFrame),""", """
		Button_Multiplayer = (Frame_Global.GetFirstChild("button-quickswitch-multiplayer") as CMlFrame),"""));
    patches.AddPatch(AppendPatch("""
	CMlFrame Button_Play;""", """
	CMlFrame Button_Multiplayer;"""));

    
    // // move button play
    // patches.AddPatch("pos=\"-82.5943 42.\"", "pos=\"-80.2562 48.63.\"");
    // // move button clubs
    // patches.AddPatch("pos=\"-84.9324 28.74\"", "pos=\"-84.9324 22.11\"");
    // // move button create
    // patches.AddPatch("pos=\"-87.2705 15.48\"", "pos=\"-87.2705 8.85\"");
    // // move button ubisoft connect
    // patches.AddPatch("pos=\"-89.6086 2.22\"", "pos=\"-89.6086 -4.41\"");
    // // move button news
    // patches.AddPatch("pos=\"-94.9143 -27.8702\"", "pos=\"-94.9143 -34.5002\"");
    // // move button news tabs
    // patches.AddPatch("pos=\"-66.1441 -47.2582\"", "pos=\"-66.1441 -53.6462\"");
    patches.AddPatch("data-nav-targets=\"_;_;button-settings;button-clubs;_;_\"", "data-nav-targets=\"_;_;button-settings;button-quickswitch-multiplayer;_;_\"");
    patches.AddPatch("data-nav-targets=\"_;_;button-play;button-create;_;_\"", "data-nav-targets=\"_;_;button-quickswitch-multiplayer;button-create;_;_\"");

    return patches;
}
