package haxeplus;

import flixel.FlxSprite;
import flixel.FlxG;
import flixel.ui.FlxButton;
import flixel.input.mouse.FlxMouseEventManager;
import flixel.util.FlxColor;
import flixel.text.FlxText;
import flixel.FlxCamera;
import flixel.group.FlxGroup;
import flixel.FlxObject;


class Debugger
{

	public static var instance:Debugger;

	public var selectionObject:FlxSprite;

	private var group:FlxGroup;
	private var camera:FlxCamera;


	private var obj:FlxText;
	private var x:FlxText;
	private var y:FlxText;

	private var scaleX:FlxText;
	private var scaleY:FlxText;

	private var rotation:FlxText;

	var index:Int;

	static var cameraIndex:Int = 0;


	private var remove:FlxButton;

	public function new()
	{
	}

	static  var multiplier = 1000000;
    
	static function round(value:Float):String
    return Std.string(Math.round(value * multiplier) / multiplier);


	public static function create(group:FlxGroup, camera:FlxCamera)
	{
		#if debug
		instance = new Debugger();
		instance.init(group, camera);
		#end
	}

	public function init(group:FlxGroup, camera:FlxCamera)
	{
		FlxMouseEventManager.init();

		this.group = group;
		this.camera = camera;

		initDebugObjects();
	}

	private function createShitText(color:FlxColor = FlxColor.WHITE): FlxText
	{
		var text = new FlxText(30, FlxG.height - 30 * (index + 1), 0, "", 20);
		text.setFormat(Paths.font("vcr.ttf"), 20, color, RIGHT);
		text.setBorderStyle(OUTLINE, 0xFF000000, 3, 1);
		text.scrollFactor.set();

		group.add(text);
		text.cameras = [camera];

		index ++;

		return text;
	}

	private function createShitButton(buttonLabel:String): FlxButton
	{
		var button = new FlxButton(30, FlxG.height - 30 * (index + 1), buttonLabel, function onClick()
		{
			selectionObject = null;
		});

		group.add(button);
		button.cameras = [camera];

		index ++;

		return button;
	}

	private function initDebugObjects()
	{

		obj = createShitText(FlxColor.RED);
		x = createShitText();
		y = createShitText();
		scaleX = createShitText();
		scaleY = createShitText();
		rotation = createShitText();
		remove = createShitButton("Remove");
		update(0);

	}


	public function Debug(obj:FlxSprite)
	{
		UnSelect();

		this.selectionObject = obj;
		this.selectionObject.color = FlxColor.RED;
	}

	public function UnSelect()
	{
		if (this.selectionObject == null)
			return;

		this.selectionObject.color = FlxColor.WHITE;
		this.selectionObject = null;
	}
	

	private function updateCamera()
	{
		if (FlxG.keys.anyJustPressed([C])) 
		{
			var cams =  FlxG.cameras.list;
			if(cams == null || cams.length == 0) return;

			cameraIndex++;
			if (cameraIndex >= cams.length) 
			{
				cameraIndex = 0;
			}

			camera = cams[cameraIndex];

			group.remove(obj);
			group.remove(x);
			group.remove(y);
			group.remove(scaleX);
			group.remove(scaleY);
			group.remove(rotation);
			group.remove(remove);

			UnSelect();
			create (group, camera); 
		}
	}

	private function appendControlHepler(text:String, control:String) :String
	{
		var maxDescription:Int = 50;

		var daLength = (30 - text.length);

		for (i in 0...daLength) 
		{
			text += " ";
		}

		text += control;

		return text;
	}

	public function update(elapsed:Float)
	{

		if (selectionObject == null)
		{
			obj.text = "SELECT AN OBJECT TO DEBUG!";
			y.text = "";
			x.text = "";
			scaleX.text = "";
			scaleY.text = "";
			rotation.text = "";
			remove.visible = false;
			return;
		}

		var flipX = selectionObject.flipX;
		var flipY = selectionObject.flipY;


		obj.text = selectionObject.debugName().toUpperCase();
		x.text = "x: " +  selectionObject.x + " | flip X: " + flipX;
		y.text = "y: " +  selectionObject.y + " | flip Y: " + flipY;


		if (selectionObject.scale != null) 
		{
			scaleX.text = "scale X: " + round(selectionObject.scale.x);
			scaleY.text = "scale Y: " + round(selectionObject.scale.y);
		}
	
		rotation.text = "rotation: " + round(selectionObject.angle);
		remove.visible = true;


		x.text = appendControlHepler(x.text, "|←↓↑→| |ASWD| |JKIL| - X -");
		y.text = appendControlHepler(y.text, "|←↓↑→| |ASWD| |JKIL| - Y -");

		scaleX.text = appendControlHepler(scaleX.text, "|[]|");
		scaleY.text = appendControlHepler(scaleY.text, "|;'|");

		rotation.text = appendControlHepler(rotation.text, "|,.|");

		var upP = FlxG.keys.anyPressed([W, UP, I]);
		var rightP = FlxG.keys.anyPressed([D, RIGHT, L]);
		var downP = FlxG.keys.anyPressed([S, DOWN, K]);
		var leftP = FlxG.keys.anyPressed([A, LEFT, J]);

		var scaleXNeg = FlxG.keys.anyPressed([LBRACKET]);
		var scaleXPos = FlxG.keys.anyPressed([RBRACKET]);

		var scaleYNeg = FlxG.keys.anyPressed([SEMICOLON]);
		var scaleYPos = FlxG.keys.anyPressed([QUOTE]);

		var rotationNes = FlxG.keys.anyPressed([COMMA]);
		var rotationPos = FlxG.keys.anyPressed([PERIOD]);




		var fX = FlxG.keys.anyJustPressed([X]);
		var fY = FlxG.keys.anyJustPressed([Y]);

		
		var multiplier = 1;
		var holdShift = FlxG.keys.pressed.SHIFT;
		if (holdShift)
			multiplier = 5;

		//------------- position ----------
		if (upP)
			selectionObject.y -= 1 * multiplier;
		if (downP)
			selectionObject.y += 1 * multiplier;
		if (leftP)
			selectionObject.x -= 1 * multiplier;
		if (rightP)
			selectionObject.x += 1 * multiplier;


		//-------------- rotation -----------
		if(rotationPos)
			selectionObject.angle += elapsed * multiplier * 2;

		if(rotationNes)
			selectionObject.angle -= elapsed * multiplier * 2;

		//--------------- scale -------------
		if(scaleXNeg || (scaleYNeg && holdShift))
			selectionObject.scale.x	 -= elapsed;

		if(scaleXPos || (scaleYPos && holdShift))
			selectionObject.scale.x += elapsed ;

		if(scaleYNeg || (scaleXNeg && holdShift))
			selectionObject.scale.y -= elapsed ;

		if(scaleYPos || (scaleXPos && holdShift))
			selectionObject.scale.y += elapsed ;

		//---------------- flip --------------

		if(fX)
			selectionObject.flipX = !selectionObject.flipX;
	
		if(fY) 
			selectionObject.flipY = !selectionObject.flipY;

		updateCamera();

	}


}