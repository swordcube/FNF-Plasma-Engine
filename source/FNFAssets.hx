package;

import flixel.FlxG;
import flixel.graphics.FlxGraphic;
import flixel.graphics.frames.FlxAtlasFrames;
import openfl.display.BitmapData;
import openfl.media.Sound;
import sys.FileSystem;
import sys.io.File;

using StringTools;

enum FNFAssetType {
    IMAGE;
    SPARROW;
    PACKER;
    STORY_CHARACTER_SPARROW;
    CHARACTER_SPARROW;
    CHARACTER_PACKER;
    SOUND;
    TEXT;
}

@:enum abstract ImageExt(String) to String {
	var PNG = '.png';
	var JPG = '.jpg';
    var BMP = '.bmp';
}

@:enum abstract SoundExt(String) to String {
	var OGG = '.ogg';
	var MP3 = '.mp3';
	var WAV = '.wav';
}

@:enum abstract FontExt(String) to String {
	var TTF = '.ttf';
	var OTF = '.otf';
}

class FNFAssets {
    /**
        The asset cache.
    **/
    public static var cache:Map<String, Dynamic> = [];

    /**
        The asset cache. except it doesn't clear!!!!1 (used for PreloadState)
    **/
    public static var permCache:Map<String, Dynamic> = [];

    /**
        A function to clear the cache of a specific type, or everything in the `cache` map.

        @param type           The type of cache to remove (set to `null` (default) to clear all cache)
    **/
    public static function clearCache(type:Null<String> = null)
    {
        switch(type.toLowerCase())
        {
            // Clears all images from cache
            case "image":
                for(fucker in cache.keys())
                {
                    if(fucker != null && fucker.endsWith(":IMAGE")) {
                        var graphic:FlxGraphic = cast(cache[fucker], FlxGraphic);
                        graphic.dump();
                        graphic.destroy();
                        cache.remove(fucker);
                    }
                }

            // Clears all sounds from cache
            case "sound":
                for(fucker in cache.keys())
                {
                    if(fucker != null && fucker.endsWith(":SOUND")) {
                        cache.remove(fucker);
                    }
                }
                
            // Clear all cache if the type doesn't exist
            default:
                for(fucker in cache.keys())
                {
                    if(fucker != null && fucker.endsWith(":IMAGE")) {
                        var graphic:FlxGraphic = cast(cache[fucker], FlxGraphic);
                        graphic.dump();
                        graphic.destroy();
                        cache.remove(fucker);
                    }

                    if(fucker != null && fucker.endsWith(":SOUND")) {
                        cache.remove(fucker);
                    }
                }

                cache.clear();
        }
    }

    /**
        Returns an asset with a type of:
        IMAGE, SOUND, or TEXT.
        from `path`

        @param type                    The asset type.
        @param path                    The path to get the asset from.
        @param packOverride            A pack to get this asset from (null = current pack, anything else will forcefully try to load it from that pack if it exists there)
    **/
    public static function returnAsset(type:FNFAssetType, path:String):Dynamic
    {
        switch(type)
        {
            case IMAGE:
                return returnGraphic(path);

            case SPARROW:
                return FlxAtlasFrames.fromSparrow(returnGraphic(AssetPaths.image(path)), returnText(AssetPaths.xml('images/$path')));

            case PACKER:
                return FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic(AssetPaths.image(path)), returnText(AssetPaths.txt('images/$path')));

            case STORY_CHARACTER_SPARROW:
                return FlxAtlasFrames.fromSparrow(returnGraphic(AssetPaths.storyCharacterSpriteSheet(path)), returnText(AssetPaths.xml('story_characters/$path/spritesheet')));

            case CHARACTER_SPARROW:
                return FlxAtlasFrames.fromSparrow(returnGraphic(AssetPaths.characterSpriteSheet(path)), returnText(AssetPaths.xml('characters/$path/spritesheet')));

            case CHARACTER_PACKER:
                return FlxAtlasFrames.fromSpriteSheetPacker(returnGraphic(AssetPaths.characterSpriteSheet(path)), returnText(AssetPaths.txt('characters/$path/spritesheet')));

            case SOUND:
                if(!FileSystem.exists(path))
                    return null;

                // if it exists in perm cache then get that instead
                if(permCache.exists(path+":SOUND"))
                    return permCache.get(path+":SOUND");

                // otherwise actually manage the cache and shit
                if(!cache.exists(path+":SOUND"))
                    cache.set(path+":SOUND", Sound.fromFile(path));
        
                return cache.get(path+":SOUND");

            case TEXT:
                return returnText(path);
                
            default:
                trace('type: ${type.getName()} doesn\'t do anything or it doesn\'t exist so it\'s gonna return null');
        }

        return null;
    }

    /**
        Returns an FlxGraphic from `path`.

        @param path           The path.
    **/
    public static function returnGraphic(path:String):FlxGraphic
    {
        // if it doesn't exist give up and return null
         if(!FileSystem.exists(path))
            return null;

        // if it exists in perm cache then get that instead
        if(permCache.exists(path+":IMAGE"))
            return permCache.get(path+":IMAGE");

        // otherwise actually manage the cache and shit
        if(!cache.exists(path + ":IMAGE"))
        {
            var newGraphic:FlxGraphic = FlxGraphic.fromBitmapData(BitmapData.fromFile(path), false, path + ":IMAGE", false);

            newGraphic.destroyOnNoUse = false;
            newGraphic.persist = true;

            cache.set(path + ":IMAGE", newGraphic);

            return newGraphic;
        }

        return cache.get(path + ":IMAGE");
    }

    /**
        Returns the contents of `path` as a string.

        @param path           The path.
    **/
    public static function returnText(path:String):String
    {
        if(FileSystem.exists(path))
            return File.getContent(path);

        return "";
    }
}