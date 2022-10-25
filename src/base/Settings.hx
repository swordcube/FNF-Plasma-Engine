package base;

enum SettingType {
    Checkbox;
    Selector;
    Number;
}

typedef Setting = {
    var name:String;
    var desc:String;
    var type:SettingType;
    @:optional var limits:Array<Float>; // Used for Numbers
    @:optional var decimals:Float; // Used for Numbers
    @:optional var increment:Float; // Used for Numbers
    @:optional var values:Array<Dynamic>; // Used for Selectors
    var value:Any;
};

class Settings {
    public static final settings:Map<String, Array<Setting>> = [
        "Preferences" => [
            {
                name: "Downscroll",
                desc: "Makes your notes move downwards instead of upwards.",
                type: Checkbox,
                value: false
            },
            {
                name: "Centered Notes",
                desc: "Makes your notes centered and hides the opponent's notes.",
                type: Checkbox,
                value: false
            },
            {
                name: "Ghost Tapping",
                desc: "Allows you to press keys while there are no notes able to be hit.",
                type: Checkbox,
                value: true
            },
            {
                name: "Auto Pause",
                desc: "Choose whether or not to pause the game automatically if the window is unfocused.",
                type: Checkbox,
                value: true
            },
            {
                name: "Note Offset",
                desc: "Allows you to press keys while there are no notes able to be hit.",
                type: Number,
                increment: 5,
                limits: [-1000, 1000],
                value: 0
            },
            {
                name: "Framerate Cap",
                desc: "Change how high your FPS can go.",
                type: Number,
                increment: 10,
                limits: [30, 1000],
                value: 1000
            },
        ],
        "Appearance" => [
            {
                name: "FPS Counter",
                desc: "Choose whether or not to display the FPS at the top left of the screen.",
                type: Checkbox,
                value: true
            },
            {
                name: "Memory Counter",
                desc: "Choose whether or not to display the memory at the top left of the screen.",
                type: Checkbox,
                value: true
            },
            {
                name: "Display Version",
                desc: "Choose whether or not to display the engine version at the top left of the screen.",
                type: Checkbox,
                value: true
            },
            {
                name: "Note Splashes",
                desc: "'Choose whether or not to enable note splashes in gameplay. Disable if you find them distracting.",
                type: Checkbox,
                value: true
            },
        ]
    ];

    public static var settingsMap:Map<String, Any> = [];

    /**
     * Load the settings from save data.
     */
    public static function init() {
        for(a in settings) {
            for(s in a) {
                var reflectGet = Reflect.getProperty(FlxG.save.data, s.name);
                if(reflectGet != null)
                    settingsMap[s.name] = reflectGet;
                else {
                    Reflect.setProperty(FlxG.save.data, s.name, s.value);
                    FlxG.save.flush();
                    settingsMap[s.name] = s.value;
                }
            }
        }
    }

    /**
     * Returns the value for the setting called `s`.
     * @param s The setting to get
     */
    public static function get(s:String) {
        return settingsMap[s];
    }

    /**
     * Sets the value of the setting called `s` to `v`
     * 
     * (WARNING: Doesn't automatically flush! Use the `flush()` function to do this!)
     * @param s The setting to modify
     * @param v The value to set the setting to
     */
    public static function set(s:String, v:Dynamic) {
        settingsMap[s] = v;
    }

    /**
     * Saves all settings to the disk to be loaded when opening the game.
     */
    public static function flush() {
        for(k=>s in settingsMap)
            Reflect.setProperty(FlxG.save.data, k, s);
        FlxG.save.flush();
    }
}