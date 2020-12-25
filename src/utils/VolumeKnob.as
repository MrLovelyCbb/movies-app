package  utils
{
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.MouseEvent;
	
	/**
	 * ...
	 * @author Andreas Renberg (IqAndreas)
	 */
	public class VolumeKnob extends Sprite
	{
		
		public function VolumeKnob(displayKnob:DisplayObject, startVolume:Number = 1, degreesPerVolume:int = 360, startAngle:Number = 0):void
		{
			this.displayKnob = displayKnob;
			this.volume = startVolume;
			this.angle = startAngle;
			this.degreesPerVolume = degreesPerVolume;
			
			if (this.stage) 
				{ this.addListeners(); }
			else 
				{ addEventListener(Event.ADDED_TO_STAGE, this.addListeners); }
		}
		
		
		// -------------------------------------------------------------------------
		//		EVENTS
		// -------------------------------------------------------------------------
		
		public static const VOLUME_CHANGED:String = "volumeChanged";
		
		
		// -------------------------------------------------------------------------
		//		GETTER / SETTER METHODS
		// -------------------------------------------------------------------------
		
		private var _enabled:Boolean = true;
		public function get enabled():Boolean
		{ return _enabled; }
		public function set enabled(new_enabled:Boolean):void
		{ _enabled = new_enabled; }
		
		
		
		//The Display knob rotates when the mouse moves
		private var _displayKnob:DisplayObject;
		public function get displayKnob():DisplayObject
		{ return _displayKnob; }
		public function set displayKnob(new_displayKnob:DisplayObject):void
		{
			if ((_displayKnob) && this.contains(_displayKnob))
				{ super.removeChild(_displayKnob); }
			
			_displayKnob = new_displayKnob;
			
			if (_displayKnob)
			{
				//I use "super" instead of "this", because I prevented 
				//children from being added via "this".
				super.addChild(_displayKnob);
				_displayKnob.rotation = this.angle;
			}
		}
		
		
		//Note, it has nothing to do with this.rotation property
		private var _angle:Number = 0;
		public function get angle():Number
		{ return _angle; }
		public function set angle(new_angle:Number):void
		{
			_angle = new_angle;
			
			if (this.displayKnob)
				{ this.displayKnob.rotation = this.angle; }
				
		}
		
		
		//By default, one rotation around (360 degrees) sets the volume from 0 to 1.
		private var _degreesPerVolume:uint = 360;
		public function get degreesPerVolume():int
		{ return _degreesPerVolume; }
		public function set degreesPerVolume(new_degreesPerVolume:int):void
		{
			//Degrees per volume can never possibly be 0.
			//It can be a negative number, though.
			if (new_degreesPerVolume == 0)
				{ throw new ArgumentError("Error: [VolumeKnob] 'degreesPerVolume' cannot be set to 0."); }
			else
				{ _degreesPerVolume = new_degreesPerVolume; }
		}
		
		
		
		//This can be a decimal value from 0 to 1, by default it is 1.
		private var _volume:Number = 1;
		public function get volume():Number
		{ return _volume; }
		public function set volume(new_volume:Number):void
		{
			if (new_volume > 1)
				{ new_volume = 1; }
			
			if (new_volume < 0)
				{ new_volume = 0; }
			
			if (_volume != new_volume)
			{
				_volume = new_volume;
				this.dispatchEvent(new Event(VolumeKnob.VOLUME_CHANGED, false, false));
			}
		}
		
		
		/* This property was disabled until I can get the kinks out. Right now, the knob can keep on rotating.
		 
			//If this is set to true, allows the knob to keep spinning even when the
			//minimum or maximum values have been met
			private var _allowRotateAfterLimit:Boolean = true;
			public function get allowRotateAfterLimit():Boolean
			{ return _allowRotateAfterLimit; }
			public function set allowRotateAfterLimit(new_allowRotateAfterLimit:Boolean):void
			{ _allowRotateAfterLimit = new_allowRotateAfterLimit; }
			
		*/ 
		
		
		// -------------------------------------------------------------------------
		//		MOUSE EVENT CAPTURING FUNCTIONS
		// -------------------------------------------------------------------------
		private function addListeners(ev:Event = null):void
		{
			//No point in listening for mouse events if the knob isn't even on the stage.
			this.removeEventListener(Event.ADDED_TO_STAGE, addListeners);
			
			this.addEventListener(MouseEvent.MOUSE_DOWN, onMouseDown);
		}
		
		
		// VARIABLES
		private const radToDeg:Number = 180 / Math.PI;
		private var isDraggingKnob:Boolean = false;
		private var oldAngle:Number;
		
		private function onMouseDown(mouseEv:MouseEvent):void
		{
			if (isDraggingKnob)
				{ stopDragging(); }
			
			isDraggingKnob = true;
			
			//Math.atan2 returns radians, so they need to be converted to degrees
			oldAngle = Math.atan2(this.mouseY, this.mouseX) * radToDeg;
			
			//ADD EVENT LISTENERS
			stage.addEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.addEventListener(Event.DEACTIVATE, onDeactivate);
			stage.addEventListener(Event.MOUSE_LEAVE, onDeactivate);
			
			stage.addEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}
		
		private function onMouseMove(mouseEv:MouseEvent):void
		{ updateVolume(this.mouseX, this.mouseY); }
		
		private function updateVolume(newX:Number, newY:Number):void
		{
			//The isDraggingKnob is just there as a safety precaucion
			if ((isDraggingKnob) && (this.enabled))
			{
				var newAngle:Number = Math.atan2(newY, newX) * radToDeg; 
				
				//Ask me if you want to describe this more.
				//Basically, if you rotate the object past 180 degrees, it will jump to -180,
				//creating a 360 degree difference instead of the one or two degrees you turned it.
				if ((oldAngle < -90) && (newAngle > 90))
					{ oldAngle += 360; }
					
				if ((oldAngle > 90) && (newAngle < -90))
					{ oldAngle -= 360; }
				
				var angleDiff:Number = newAngle - oldAngle;
				
				//Update the rotation of the displayKnob
				this.angle += angleDiff;
				
				//Update the volume
				this.volume += (angleDiff / this.degreesPerVolume);
				
				oldAngle = newAngle;
			}
		}
		
		
		private function onMouseUp(mouseEv:MouseEvent):void
		{
			updateVolume(this.mouseX, this.mouseY);
			stopDragging();
		}
		
		private function onDeactivate(ev:Event):void
		{
			//Assume that if the mouse leaves the stage or the SWF has lost focus,
			//the dragging will end
			stopDragging();
		}
		
		private function stopDragging():void
		{
			isDraggingKnob = false;
			
			//ADD EVENT LISTENERS
			stage.removeEventListener(MouseEvent.MOUSE_UP, onMouseUp);
			stage.removeEventListener(Event.DEACTIVATE, onDeactivate);
			stage.removeEventListener(Event.MOUSE_LEAVE, onDeactivate);
			
			stage.removeEventListener(MouseEvent.MOUSE_MOVE, onMouseMove);
		}		
		
		
		
		// -------------------------------------------------------------------------
		//		OVERRIDDEN CHILD HANDLING METHODS
		// -------------------------------------------------------------------------
		
		//Users are not allowed to add children to the knob directly
		//but must instead set the "displayKnob" property
		
		//I used error number 2080 because it is similar to:
		//Loader's 2069 error - http://iqandreas.blogspot.com/2009/09/error-error-2069-loader-class-does-not.html
		//Stage's 2071 error - http://iqandreas.blogspot.com/2009/09/error-error-2071-stage-class-does-not.html
		
		
		private function get oneChildOnlyError():Error
		{
			var err:Error = new Error("[VolumeKnob] Children cannot be added or removed from VolumeKnob. Please use the \"displayKnob\" property instead.", 2080);
			err.name = "OneChildOnly Error [VolumeKnob]";
			return err;
		}
		
		public override function addChild(child:DisplayObject):DisplayObject
		{ throw this.oneChildOnlyError; }
		
		public override function addChildAt(child:DisplayObject, index:int):DisplayObject
		{ throw this.oneChildOnlyError; }
		
		public override function removeChild(child:DisplayObject):DisplayObject
		{ throw this.oneChildOnlyError; }
		
		public override function removeChildAt(index:int):DisplayObject
		{ throw this.oneChildOnlyError; }
		
		public override function setChildIndex(child:DisplayObject, index:int):void
		{ throw this.oneChildOnlyError; }
		
		public override function swapChildren(child1:DisplayObject, child2:DisplayObject):void
		{ throw this.oneChildOnlyError; }
		
		public override function swapChildrenAt(index1:int, index2:int):void
		{ throw this.oneChildOnlyError; }
		
		
	}
	
}