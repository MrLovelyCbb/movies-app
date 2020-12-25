package event
{
	import flash.events.Event;

	public class NotifyEvent extends Event
	{
		public var data:Object = null;
		
		
		public function NotifyEvent(type:String, data:Object = null, bubbles:Boolean=false, cancelable:Boolean=false)
		{
			super(type, bubbles, cancelable);
			this.data = data;
		}
		
		override public function clone():Event{
			return this;
		}
	}
}