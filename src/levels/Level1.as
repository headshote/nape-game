package levels
{
	import levels.common.*;
	import nape.callbacks.*;
	import nape.geom.*;
	import utils.*;
	
	/**
	 * Child Class of a game, add this one to parent display object
	 * @author Hammerzeit
	 */
	public class Level1 extends Game
	{
		public function Level1()
		{
			super( Vec2.get(0, 600) );
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
			var sc:Number = GameNumbers.currentScale;
			controlCamera(_actor.getPos().x + ( 800 + 400 * (sc-2) )* (sc-1) , _actor.getPos().y + ( 600 + 300 * (sc-2) ) * (sc-1), sc, 0);
			
			_actor.update();			
		}		
	}
}