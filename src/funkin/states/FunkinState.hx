package funkin.states;

import openfl.Lib;
import funkin.gameplay.Note;
import openfl.system.System;
import flixel.system.FlxSound;
import flixel.addons.transition.FlxTransitionableState;
import base.Conductor;
import flixel.FlxState;

using StringTools;

class FunkinState extends FlxState {
    var curStep:Int = 0;
	var curBeat:Int = 0;

	var curStepFloat:Float = 0;
	var curBeatFloat:Float = 0;

	public var allowSwitchingMods:Bool = true;

    override function create() {
        super.create();

        if (!FlxTransitionableState.skipNextTransOut)
			openSubState(new Transition(0.45, true));

		// Clears sounds from memory
		FlxG.sound.list.forEach(function(sound:FlxSound) {
			FlxG.sound.list.remove(sound, true);
			sound.stop();
			sound.destroy();
		});
		FlxG.sound.list.clear();

        // Clear all bitmaps from memory
		FlxG.bitmap.dumpCache();
		FlxG.bitmap.clearCache();

		// Clear all cache
		Assets.cache.clear();

        // Run the garbage collector
        System.gc();

		// Load note skins because heheheha
		Note.skinJSONs = [];
		for(json in CoolUtil.readDirectory("data/note_skins")) {
			if(FileSystem.exists(Paths.asset("data/note_skins/"+json)) && json.endsWith(".json"))
				Note.skinJSONs[json.split(".json")[0]] = TJSON.parse(Assets.load(TEXT, Paths.asset("data/note_skins/"+json)));
		}
    }

    override function update(elapsed:Float) {
		Lib.current.stage.frameRate = Settings.get("Framerate Cap");
		FlxG.autoPause = Settings.get("Auto Pause");

        var oldStep:Int = curStep;
        var oldBeat:Int = curBeat;

		var lastChange:BPMChangeEvent = {
			stepTime: 0,
			songTime: 0,
			bpm: 0
		}
		for (i in 0...Conductor.bpmChangeMap.length) {
			if (Conductor.position >= Conductor.bpmChangeMap[i].songTime)
				lastChange = Conductor.bpmChangeMap[i];
		}

		curStep = lastChange.stepTime + Math.floor((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
        curBeat = Math.floor(curStep / 4);

		curStepFloat = lastChange.stepTime + ((Conductor.position - lastChange.songTime) / Conductor.stepCrochet);
        curBeatFloat = curStepFloat / 4;

        if (oldStep != curStep && curStep > 0)
            stepHit(curStep);

        if (oldBeat != curBeat && curBeat > 0)
            beatHit(curBeat);

		if(FlxG.keys.justPressed.F5)
			Main.resetState();

		if(allowSwitchingMods && FlxG.keys.justPressed.TAB) {
            persistentUpdate = false;
            persistentDraw = true;
            openSubState(new funkin.states.substates.ModSelection());
        }

        super.update(elapsed);
    }

    public function beatHit(curBeat:Int) {}
    public function stepHit(curStep:Int) {}
}