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
	 * Child Class of a game, add this one to parent display object
	 * @author Hammerzeit
	 */
	public class Level1 extends Game
	{
		public function Level1()
		{
			super( Vec2.get(0, 600, true) );
		}
		
		override protected function init():void
		{
			var w:uint = stage.stageWidth;
			var h:uint = stage.stageHeight;	
			
			var listener1:InteractionListener = new InteractionListener(CbEvent.BEGIN, InteractionType.COLLISION, [Interactions.instance.CBTYPE_DYNAMIC_CIRCLE, Interactions.instance.CBTYPE_DYNAMIC_RECT], [Interactions.instance.CBTYPE_STATIC_CIRCLE, Interactions.instance.CBTYPE_STATIC_RECT], Interactions.instance.beginHandler, 0);
			var listener2:InteractionListener = new InteractionListener(CbEvent.ONGOING, InteractionType.COLLISION, [Interactions.instance.CBTYPE_DYNAMIC_CIRCLE, Interactions.instance.CBTYPE_DYNAMIC_RECT], [Interactions.instance.CBTYPE_STATIC_CIRCLE, Interactions.instance.CBTYPE_STATIC_RECT], Interactions.instance.ongoingHandler, 0);
			var listener3:InteractionListener = new InteractionListener(CbEvent.END, InteractionType.COLLISION, [Interactions.instance.CBTYPE_DYNAMIC_CIRCLE, Interactions.instance.CBTYPE_DYNAMIC_RECT], [Interactions.instance.CBTYPE_STATIC_CIRCLE, Interactions.instance.CBTYPE_STATIC_RECT], Interactions.instance.endHandler, 1);
			
			listener1.space = _space
			listener2.space = _space
			listener3.space = _space			
			
			readLevelData(new Level_1());
		}
		
		override protected function updates():void
		{
			controlCamera(_actor.getPos().x, _actor.getPos().y, 1, 0);
			
			_actor.update();			
		}		
	}
}