package 
{
	import com.junkbyte.console.Cc;
	import flash.display.DisplayObject;
	import flash.display.Sprite;
	import flash.events.Event;
	import windows.Menu;
	import windows.OverLay;
	
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Main extends Sprite 
	{
		private var _overlay:OverLay;
		
		public function Main():void 
		{
			if (stage) init();
			else addEventListener(Event.ADDED_TO_STAGE, init);
		}
		
		private function init(e:Event = null):void 
		{
			removeEventListener(Event.ADDED_TO_STAGE, init);
			
			// entry point
			Cc.startOnStage(this, "`");
			
			_overlay = new OverLay();
			Add( new Menu(), _overlay );
		}
		
		public function Add(...args):void
		{
			var lastChld:DisplayObject;
			for ( var arg:String in args )			
				lastChld = addChild(args[arg]);
			setChildIndex(_overlay, getChildIndex(lastChld));			
		}	
		
		public function Remove(...args):void
		{
			for ( var arg:String in args )
				removeChild(args[arg]);
		}
	}
	
}