package states;
import Controls.Control;
import Controls.KeyboardScheme;
import flash.text.TextField;
import flixel.FlxG;
import flixel.FlxSprite;
import flixel.addons.display.FlxGridOverlay;
import flixel.group.FlxGroup.FlxTypedGroup;
import flixel.input.keyboard.FlxKey;
import flixel.math.FlxMath;
import flixel.text.FlxText;
import flixel.util.FlxColor;
import lime.utils.Assets;
import flixel.addons.transition.FlxTransitionableState;
import Options;
import ui.*;
#if desktop
import Discord.DiscordClient;
#end

// TODO: turn this into a chart thing

class SoundOffsetState extends MusicBeatState
{
  public var playingAudio:Bool=false;
  public var status:FlxText;
  public var beatCounter:Float = 0;
  public var beatCounts=[];
  public var currOffset:Int = OptionUtils.options.noteOffset;
  public var offsetTxt:FlxText;
  public var metronome:Character;
  override function create(){
    super.create();
    #if desktop
    // Updating Discord Rich Presence
    DiscordClient.changePresence("Calibrating audio", null);
    #end
    var menuBG:FlxSprite = new FlxSprite().loadGraphic(Paths.image("menuBG"));

    menuBG.color = 0xFFa271de;
    menuBG.setGraphicSize(Std.int(menuBG.width * 1.1));
    menuBG.updateHitbox();
    menuBG.screenCenter();
    menuBG.antialiasing = true;
    add(menuBG);

    var title:FlxText = new FlxText(0, 20, 0, "Audio Calibration", 32);
    title.setFormat(Paths.font("vcr.ttf"), 32, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    title.screenCenter(X);
    add(title);

    status = new FlxText(0, 50, 0, "Audio is paused", 24);
    status.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    status.screenCenter(X);
    add(status);

    offsetTxt = new FlxText(0, 80, 0, "Current offset: 0ms", 24);
    offsetTxt.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    offsetTxt.screenCenter(X);
    add(offsetTxt);


    var instructions:FlxText = new FlxText(0, 125, 0, "Press the X to pause/play the beat\nPress A in time with the beat to get an approximate offset\nPress Y to reset\nPress left and right to adjust the offset manually.\nPress B to go back and save the current offset", 24);
    instructions.setFormat(Paths.font("vcr.ttf"), 24, FlxColor.WHITE, CENTER, FlxTextBorderStyle.OUTLINE, FlxColor.BLACK);
    instructions.screenCenter(X);
    add(instructions);

    metronome = new Character(FlxG.width/2,300,'gf');
    metronome.setGraphicSize(Std.int(metronome.width*.6));
    metronome.screenCenter(XY);
    metronome.y += 100;
    add(metronome);

    #if android
    addVirtualPad(LEFT_RIGHT, A_B_X_Y);
    #end
  }

  override function beatHit(){
    super.beatHit();
    beatCounter=0;
    if(playingAudio){
      FlxG.sound.play(Paths.sound('beat'),1);
      metronome.dance();
    }


  }

  override function update(elapsed:Float){
    if(playingAudio){
      if (FlxG.sound.music.volume > 0)
      {
        FlxG.sound.music.volume -= 0.5 * FlxG.elapsed;
      }
      beatCounter+=elapsed*1000;
      status.text = "Audio is playing";
      Conductor.changeBPM(50);
      Conductor.songPosition += FlxG.elapsed * 1000;
    }else{
      if (FlxG.sound.music.volume < 0.7)
      {
        FlxG.sound.music.volume += 0.5 * FlxG.elapsed;
      }
      status.text = "Audio is paused";
      Conductor.changeBPM(0);
      Conductor.songPosition = 0;
      beatCounter=0;
    }

    offsetTxt.text = 'Current offset:  ${currOffset}ms';

    status.screenCenter(X);
    if(controls.PAUSE){
      playingAudio = !playingAudio;
      if(playingAudio==false){
        OptionUtils.options.noteOffset=currOffset;
      }
    }

    if(playingAudio){
      if(controls.ACCEPT){
        beatCounts.push(beatCounter);
        var total:Float = 0;
        for(i in beatCounts){
          total+=i;
        }
        currOffset=Std.int(total/beatCounts.length);
      }
    }
    if(controls.RESET){
      beatCounts = [];
      currOffset = 0;
    }
    if(controls.BACK){
      OptionUtils.options.noteOffset = currOffset;
      OptionUtils.saveOptions(OptionUtils.options);
      FlxG.switchState(new OptionsState());
    }

      if(controls.LEFT_P){
        currOffset--;
      };
      if(controls.RIGHT_P){
        currOffset++;
      };
      if(controls.UP){
        currOffset--;
      };
      if(controls.DOWN){
        currOffset++;
      };

    super.update(elapsed);
  }

}
