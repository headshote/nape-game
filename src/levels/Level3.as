package levels
{
	import flash.display.Sprite;
	import flash.events.KeyboardEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import gameplay.Actor;
	import levels.common.Game;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.geom.Vec2;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Interactor;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import utils.Interactions;
	
	/**
	 * ...
	 * @author Hammerzeit
	 */
	public class Level3 extends Game
	{
		public function Level3()
		{
			super( Vec2.get(0, 300, true) );
		}
		
		override protected function init():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;				
			
			readLevelData(new Level_3());
		}
		
		override protected function updates():void
		{
			controlCamera(_mousePoint.x, _mousePoint.y, 1, 0);			
		}		
	}
}