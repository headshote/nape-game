package 
{
	import com.junkbyte.console.*;
	import flash.display.*;
	import flash.events.*;
	import utils.*;
	import windows.*;
	
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
			Cc.addSlashCommand("scale", setGameScale);
			Cc.addSlashCommand("exprad", setExplosionRadius);
			Cc.addSlashCommand("expstr", setExplosionStrength);
			
			_overlay = new OverLay();
			Add( new Menu(), _overlay );
		}
		
		private function setExplosionStrength(str:Number):void 
		{
			GameNumbers.expStrength = str;
		}
		
		private function setExplosionRadius(rad:Number):void 
		{
			GameNumbers.expRadius = rad;
		}
		
		private function setGameScale(scale:Number):void 
		{
			GameNumbers.currentScale = scale;
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