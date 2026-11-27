package options;

import objects.Character;

class GraphicsSettingsSubState extends BaseOptionsMenu
{
	var antialiasingOption:Int;
	var boyfriend:Character = null;
	public function new()
	{
		title = Language.getPhrase('graphics_menu', 'Graphics Settings');
		rpcTitle = 'Graphics Settings Menu'; //for Discord Rich Presence

		boyfriend = new Character(840, 170, 'bf', true);
		boyfriend.setGraphicSize(Std.int(boyfriend.width * 0.75));
		boyfriend.updateHitbox();
		boyfriend.dance();
		boyfriend.animation.finishCallback = function (name:String) boyfriend.dance();
		boyfriend.visible = false;

		//I'd suggest using "Low Quality" as an example for making your own option since it is the simplest here
		var option:Option = new Option('Low Quality', //Name
			'If checked, disables some background details,\ndecreases loading times and improves performance.', //Description
			'lowQuality', //Save data variable name
			BOOL); //Variable type
		addOption(option);

		var option:Option = new Option('Performance Mode', //Name
			'Same effect as Low Quality (simpler backgrounds, splash cap),\nbut does NOT disable Shaders.', //Description
			'performanceMode',
			BOOL);
		addOption(option);

		var option:Option = new Option('Smooth Health Bar', //Name
			"If checked, the health bar eases toward its new value\ninstead of jumping instantly when you gain or lose health.",
			'smoothHealthBar',
			BOOL);
		addOption(option);

		var option:Option = new Option('Anti-Aliasing',
			'If unchecked, disables anti-aliasing, increases performance\nat the cost of sharper visuals.',
			'antialiasing',
			BOOL);
		option.onChange = onChangeAntiAliasing; //Changing onChange is only needed if you want to make a special interaction after it changes the value
		addOption(option);
		antialiasingOption = optionsArray.length-1;

		var option:Option = new Option('Shaders', //Name
			"If unchecked, disables shaders.\nIt's used for some visual effects, and also CPU intensive for weaker " + Main.platform + ".", //Description
			'shaders',
			BOOL);
		addOption(option);

		var option:Option = new Option('GPU Caching', //Name
			#if android
			// Phrasing here matters: Android GPUs are (almost always) integrated, sharing one
			// physical memory pool with the rest of the system, so the "shitty Graphics Card"
			// warning below (written for discrete desktop GPUs with their own separate VRAM)
			// doesn't describe the actual tradeoff on this platform - it's on by default here
			// precisely because it reduces the RAM pressure that leads to low-end crashes.
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nRecommended on for most Android devices - keep it checked unless you notice visual issues.", //Description
			#else
			"If checked, allows the GPU to be used for caching textures, decreasing RAM usage.\nDon't turn this on if you have a shitty Graphics Card.", //Description
			#end
			'cacheOnGPU',
			BOOL);
		addOption(option);

		var option:Option = new Option('Max Note Splashes', //Name
			"Limits how many note splashes can be on screen at once.\nLower values improve performance on weaker " + Main.platform + ".\nSet to 0 for no limit.", //Description
			'maxNoteSplashes',
			INT);
		option.minValue = 0;
		option.maxValue = 20;
		option.displayFormat = '%v';
		option.scrollSpeed = 2;
		addOption(option);

		var option:Option = new Option('Max Active Shaders', //Name
			"Limits how many Runtime Shaders can run at once during a song.\nLower values improve performance on weaker " + Main.platform + ".\nSet to 0 for no limit.", //Description
			'maxActiveShaders',
			INT);
		option.minValue = 0;
		option.maxValue = 20;
		option.displayFormat = '%v';
		option.scrollSpeed = 2;
		addOption(option);

		var option:Option = new Option('Aggressive Memory Cleanup', //Name
			"If checked, forces a heavy garbage collection pass every time\nyou resume from the Pause menu. Can reduce RAM usage at the\ncost of a short freeze when resuming.", //Description
			'aggressiveMemoryCleanup',
			BOOL);
		addOption(option);

		var option:Option = new Option('New Fps Counter', //Name
			"Chooses what the performance overlay shows: just the FPS,\njust the memory usage, or both. It no longer shows the\ndevice's OS or API info.", //Description
			'fpsCounterMode',
			STRING,
			['FPS', 'Memory', 'Both']);
		addOption(option);

		#if !html5 //Apparently other framerates isn't correctly supported on Browser? Probably it has some V-Sync shit enabled by default, idk
		var option:Option = new Option('Framerate',
			"Pretty self explanatory, isn't it?",
			'framerate',
			INT);
		addOption(option);

		final refreshRate:Int = FlxG.stage.application.window.displayMode.refreshRate;
		option.minValue = 60;
		option.maxValue = 240;
		option.defaultValue = Std.int(FlxMath.bound(refreshRate, option.minValue, option.maxValue));
		option.displayFormat = '%v FPS';
		option.onChange = onChangeFramerate;
		#end

		var option:Option = new Option('FPS Rework',
			"If checked, this works around the game becoming \"slow\" and \"smooth\" when the current FPS is lower than the FPS cap.",
			'fpsRework',
			BOOL);
		addOption(option);

		super();
		insert(1, boyfriend);
	}

	function onChangeAntiAliasing()
	{
		for (sprite in members)
		{
			var sprite:FlxSprite = cast sprite;
			if(sprite != null && (sprite is FlxSprite) && !(sprite is FlxText)) {
				sprite.antialiasing = ClientPrefs.data.antialiasing;
			}
		}
	}

	function onChangeFramerate()
	{
		if(ClientPrefs.data.framerate > FlxG.drawFramerate)
		{
			if (ClientPrefs.data.fpsRework)
				FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
			else
			{
				FlxG.updateFramerate = ClientPrefs.data.framerate;
				FlxG.drawFramerate = ClientPrefs.data.framerate;
			}
		}
		else
		{
			if (ClientPrefs.data.fpsRework)
				FlxG.stage.window.frameRate = ClientPrefs.data.framerate;
			else
			{
				FlxG.drawFramerate = ClientPrefs.data.framerate;
				FlxG.updateFramerate = ClientPrefs.data.framerate;
			}
		}
	}

	override function changeSelection(change:Int = 0)
	{
		super.changeSelection(change);
		boyfriend.visible = (antialiasingOption == curSelected);
	}
}