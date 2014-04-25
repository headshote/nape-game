package levels.common 
{
	import flash.display.DisplayObject;
	import flash.display.DisplayObjectContainer;
	import flash.display.NativeMenuItem;
	import flash.display.Sprite;
	import flash.events.Event;
	import flash.events.KeyboardEvent;
	import flash.events.MouseEvent;
	import flash.geom.Matrix;
	import flash.geom.Point;
	import flash.geom.Rectangle;
	import flash.ui.Keyboard;
	import flash.utils.getQualifiedClassName;
	import flash.utils.getTimer;
	import gameplay.Actor;
	import gameplay.PhysicsElement;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.constraint.MotorJoint;
	import nape.constraint.PivotJoint;
	import nape.geom.Mat23;
	import nape.geom.Vec2;
	import nape.geom.Vec3;
	import nape.phys.Body;
	import nape.phys.BodyList;
	import nape.phys.BodyType;
	import nape.phys.Interactor;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.space.Space;
	import nape.util.BitmapDebug;
	import nape.util.Debug;
	import utils.Parser;
	import windows.Levels;
	
	/**
	 * Base class for game levels.
	 * Create child class that extends this one and add it to main display container
	 * @author Hammerzeit
	 */	
	public class Game extends Sprite
	{
		protected var _gravity:Vec2;
		protected var _space:Space;
		
		protected var _debugView:Debug;
		protected var _drawDebugData:Boolean;
		
		protected var _prevTime:uint;
		protected var _deltaTime:Number;
		protected var _prevDeltaTime:Number;
		protected var _simTime:Number;
		
		private const _maxS:Number = 1 / 10;
		private	const _minS:Number = 1 / 65;
		
		protected var _mouseJoint:PivotJoint;
		
		protected var _camera:Sprite;
		protected var _camH:Number;
		protected var _camW:Number;
		
		protected var _actor:Actor;
		
		private var _pressedKeys:Array;
		
		//Interaction listeners
		private var _listener1:InteractionListener;
		private var _listener2:InteractionListener;
		private var _listener3:InteractionListener;	
		private var _escPressed:Boolean;
		
		private var _middleClicked:Boolean;
		
		protected var _mousePoint:Vec2;
		
		protected var _pause:Boolean;
		
		public function Game(gr:Vec2) 
		{
			super();
			_gravity = gr;
			if ( stage )
				start();
			else
				addEventListener(Event.ADDED_TO_STAGE, start);
		}
		
		/**
		 * Main initialization code
		 * @param	e
		 */
		private function start(e:Event=null):void 
		{			
			if (e)
				removeEventListener(Event.ADDED_TO_STAGE, start);
			
			_pressedKeys = new Array();
			
			stage.focus = this;
			
			//Camera
			_camera = new Sprite();
			_camera.graphics.beginFill(0x00ff00, 0.25);
			_camera.graphics.drawRect( 0, 0, 800, 600);
			var bRect:Rectangle = _camera.getBounds(_camera);
			_camera.mouseChildren = false;
			_camera.mouseEnabled = false;
			_camera.visible = false;
			_camW = bRect.width;
			_camH = bRect.height;
			this.addChild(_camera);
		
			_space = new Space(_gravity);
			
			_mouseJoint = new PivotJoint(_space.world, null, Vec2.weak(), Vec2.weak());
			_mouseJoint.space = _space;
			_mouseJoint.active = false;
			_mouseJoint.stiff = false;
			
			stage.addEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.addEventListener(KeyboardEvent.KEY_UP, keyReleased);
			addEventListener(Event.ENTER_FRAME, update);
			addEventListener(Event.REMOVED, destroy);
			addEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			addEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);
			addEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, middleClicked);
			addEventListener(MouseEvent.MIDDLE_MOUSE_UP, middleUnClicked);
			
			_prevTime = getTimer();	
			_prevDeltaTime = 33.0;
			_simTime = 0.0;			
			
			//Add listeners to interaction between bodies of any types for collisions for events end, ongoing, begin
			_listener1 = new InteractionListener( CbEvent.BEGIN, InteractionType.COLLISION, [CbType.ANY_BODY],
												[CbType.ANY_BODY], beginHandler, 1 );
			_listener2 = new InteractionListener( CbEvent.ONGOING, InteractionType.COLLISION, [CbType.ANY_BODY],
												[CbType.ANY_BODY], ongoingHandler, 0 );
			_listener3 = new InteractionListener( CbEvent.END, InteractionType.COLLISION, [CbType.ANY_BODY],
												[CbType.ANY_BODY], endHandler, 2 );
			
			_space.listeners.add(_listener1);
			_space.listeners.add(_listener2);
			_space.listeners.add(_listener3);
			
			init();
			
			//Create debug view
			_debugView = new BitmapDebug(stage.stageWidth, stage.stageHeight);
			_drawDebugData = true;
			_debugView.drawConstraints = true;
            addChild(_debugView.display);
		}		
		
		/**
		 * This function listens to beginnings of interaction between bodies
		 * @param	cb
		 */
		protected function beginHandler(cb:InteractionCallback):void 
		{
			var firstObject:Interactor = cb.int1;
			var secondObject:Interactor = cb.int2;		
			
			var dataA:* = firstObject.userData;
			var dataB:* = secondObject.userData;
			
			if ( dataA &&  dataA.hasOwnProperty("type") )
				var stat:* = dataA.type == "actor" ? dataA : null;
			if ( dataB &&  dataB.hasOwnProperty("type") )
				stat = dataB.type == "actor" ? dataB : stat;
				
			if (stat)
			{
				stat["inAir"] = false;
			}
		}
		
		/**
		 * This function listens to interactions while they are in progress
		 * @param	cb
		 */
		protected function ongoingHandler(cb:InteractionCallback):void 
		{
			var firstObject:Interactor = cb.int1;
			var secondObject:Interactor = cb.int2;
			
			var dataA:* = firstObject.userData;
			var dataB:* = secondObject.userData;
			
			if ( dataA &&  dataA.hasOwnProperty("type") )
				var stat:* = dataA.type == "actor" ? dataA : null;
			if ( dataB &&  dataB.hasOwnProperty("type") )
				stat = dataB.type == "actor" ? dataB : stat;
				
			if (stat)
			{
				stat["inAir"] = false;
			}
		}
		
		/**
		 * This function listens to end of interactions between bodies
		 * @param	cb
		 */
		protected function endHandler(cb:InteractionCallback):void 
		{
			var firstObject:Interactor = cb.int1;
			var secondObject:Interactor = cb.int2;	
			
			var dataA:* = firstObject.userData;
			var dataB:* = secondObject.userData;
			
			if ( dataA  )
				var stat:* = dataA.type == "actor" ? dataA : null;
			if ( dataB  )
				stat = dataB.type == "actor" ? dataB : stat;
			
			if (stat)
			{
				stat["inAir"] = true;
			}
		}
		
		/**
		 * This one is used to read level data from some diplay obj. container
		 * @param	lvl - display object container with game objects
		 */
		protected function readLevelData(lvl:DisplayObjectContainer):void
		{
			var len:int = lvl.numChildren;
			var levelObject:DisplayObject;
			var joints:Vector.<Vec3> = new Vector.<Vec3>();
			
			for ( var i:int = 0; i < len; i++ )
			{
				var groupAndMask:Array;
				
				levelObject = lvl.getChildAt(i);
				
				switch ( Parser.getClassType(levelObject) )
				{					
					case Parser.TYPE_ACTOR:
						_actor = new Actor(levelObject as  DisplayObjectContainer, _space, this);
						break;
					case Parser.TYPE_JOINT:
						var motorRate:Number = Parser.parseJointName( levelObject.name );
						joints.push( Vec3.get( levelObject.x, levelObject.y, motorRate ) );
						break;
					case Parser.TYPE_OBJECT:
						groupAndMask = Parser.parsePhysicsObjName( levelObject.name )
						if ( groupAndMask )
							new PhysicsElement( Parser.getClassName(levelObject), levelObject as DisplayObjectContainer, _space, null, groupAndMask[0], groupAndMask[1] );
						else
							new PhysicsElement( Parser.getClassName(levelObject), levelObject as DisplayObjectContainer, _space, null );
						break;
				}
			}
			
			findBodiesForJoints( joints );
		}				
		
		/**
		 * Reads array of joint coords and their motor rates and connects any two bodies that fall under that joint
		 * or 1 body and game space
		 * @param	joints - Vector of Vec3's - x, y, rate
		 */
		private function findBodiesForJoints( joints:Vector.<Vec3> ):void 
		{
			for ( var i:int = 0; i < joints.length; i++ )
			{
				var jointVec:Vec2 = Vec2.get( joints[i].x, joints[i].y );
				var blist:BodyList = _space.bodiesUnderPoint( jointVec );
				var joint:PivotJoint;
				var mJoint:MotorJoint;	
				var mRate:Number = joints[i].z;
				
				if ( blist.length > 1 )
				{
					joint = new PivotJoint( blist.at(0), blist.at(1), blist.at(0).worldPointToLocal(jointVec), blist.at(1).worldPointToLocal(jointVec) );					
					joint.ignore = true
					joint.space = _space;
					if ( mRate )
					{
						mJoint = new MotorJoint( blist.at(0), blist.at(1), mRate, 1);
						mJoint.space = _space;
					}
				}
				else if ( blist.length == 1 )
				{
					joint = new PivotJoint( blist.at(0), _space.world, blist.at(0).worldPointToLocal(jointVec), _space.world.worldPointToLocal(jointVec) );
					joint.space = _space;
					if ( mRate )
					{
						mJoint = new MotorJoint( blist.at(0), _space.world, mRate, 1);
						mJoint.space = _space;
					}
				}	
				
				jointVec.dispose();
				joints[i].dispose();
			}
		}
		
		/**
		 * This one should be overridden, pregame initializations
		 */
		protected function init():void 
		{}
		
		/**
		 * Every frame stuff
		 * @param	e
		 */
		private function update(e:Event):void 
		{
			var currentTime:uint = getTimer();
			if ( currentTime == _prevTime )
				return;
			
			if ( _pause )
			{
				_prevTime = currentTime;
				return;
			}
			
			_deltaTime = (currentTime-_prevTime);
			_simTime += _deltaTime;
			
			mouseMovement();
			
			mouseDrag();			
			
			//Call update of child classes
			updates();
			
			//Nape's debug draw
			_debugView.clear();
			
			if ( _middleClicked )
				spaceExplosion( 200, _mousePoint, 100000, _space, _debugView );
			
			if ( _drawDebugData )
			{
				_debugView.draw(_space);
				_debugView.flush();
			}
			
			//Physics step, adapts to framerate
			var step:Number =  _prevDeltaTime * 0.001;			
			_space.step( step > _maxS ? (_maxS) : ( step < _minS ? (_minS) : (step) ), 10, 10);
			
			_prevTime = currentTime;
			//Smoothing of delta between updates for adaptive step
			_prevDeltaTime = ( _prevDeltaTime - (_prevDeltaTime - _deltaTime) * 0.15 );
		}
		
		/**
		 * Calculates coordinates of mouse cursor
		 */
		private function mouseMovement():void 
		{
			var xx:Number = _debugView.display.mouseX;
			var yy:Number = _debugView.display.mouseY;
				
			var trMtx:Matrix = _debugView.transform.toMatrix();
			
			if ( !_mousePoint )
				_mousePoint = Vec2.get( xx - trMtx.tx, yy - trMtx.ty );
			else
			{
				_mousePoint.x = xx - trMtx.tx;
				_mousePoint.y = yy - trMtx.ty;
			}
		}
		
		/**
		 * Mouse dragging of physical objects (first anchor)
		 */
		private function mouseDrag():void 
		{
			if (_mouseJoint.active)
			{
				_mouseJoint.anchor1.setxy(_mousePoint.x, _mousePoint.y);
				//trace(xx, yy, mousePoint.x, mousePoint.y);
			}
		}
		
		/**
		 * Querries space under mousepoint with the circle of some size.
		 * After finding bodies in this circle, makes boom!
		 * @param	qSize size of querry circle		
		 * @param	expCenter center of exp circle
		 * @param	expStr strength of eplosion
		 * @param	space game Space
		 * @param	debug debug view to display explosion circle and marker-circles of bodies inside/intersecting exp. circle		
		 */
		private function spaceExplosion(qSize:Number, expCenter:Vec2, expStr:Number, space:Space, debug:Debug):void 
		{	
			var intersectingBodies:BodyList
			var containedBodies:BodyList
			
			// Sample all bodies under a center point in a circle			
			
            // With intersection only check.
            intersectingBodies = space.bodiesInCircle(
                expCenter,
                /*radius*/ qSize,
                /*strict-containment*/ false,
                /*filter*/ null,
                intersectingBodies
            );
			// With strict containment check.
            containedBodies = space.bodiesInCircle(
                expCenter,
                /*radius*/ qSize,
                /*strict-containment*/ true,
                /*filter*/ null,
                containedBodies
            );
			
			//Output querry results	into debug sprite
			if ( debug )
			{
				debug.drawCircle(expCenter, qSize, 0xffff);
				for ( var i:int = 0; i < intersectingBodies.length; i++) 
				{
					debug.drawCircle(intersectingBodies.at(i).position, 10, 0xffff);
				}
				for (i = 0; i < containedBodies.length; i++) 
				{				
					debug.drawFilledCircle(containedBodies.at(i).position, 5, 0xffff);
				}
			}			
			
			//Filter out strictly contained bodies from the list of intersecting bodies
			intersectingBodies.filter( function (l1:Body):Boolean {
				if ( containedBodies.has(l1) )
					return false;
				return true;
			});			
			
			//Boom
			for ( i = 0; i < intersectingBodies.length; i++) 
			{
                var bod:Body = intersectingBodies.at(i);
				
				if ( bod.type == BodyType.DYNAMIC )
				{
					impulseCircular( bod, expCenter, expStr*0.25 );
				}
            }
			for (i = 0; i < containedBodies.length; i++) 
			{				
				bod = containedBodies.at(i);
				
				if ( bod.type == BodyType.DYNAMIC )
				{
					impulseCircular( bod, expCenter, expStr );
				}
            }
			
			intersectingBodies.clear();	
            containedBodies.clear();
		}
		
		/**
		 * Creates "circular explosion", gives impulse to a body depending on it's angle from center point
		 * @param	bod - body, it's position in the circle determines direction of impulse
		 * @param	centerPoint - center of circle
		 * @param	expStr - strength of the impulse
		 */
		private function impulseCircular(bod:Body, centerPoint:Vec2, expStr:Number):void 
		{
			var dx:Number = bod.position.x - centerPoint.x;
			var dy:Number = bod.position.y - centerPoint.y;
			
			var dist:Vec2 = Vec2.get( dx, dy );
			var distLen:Number = dist.length != 0 ? dist.length : 0.0001;
			
			var ang:Number = Math.atan2( dx, dy )-Math.PI/2;
			var angDeg:Number = ang * 180 / Math.PI;
			
			bod.applyImpulse( Vec2.weak( expStr * Math.cos(ang) / distLen, -expStr * Math.sin(ang) / distLen ), bod.position );
			
			dist.dispose();
		}
		
		/**
		 * Call this one every update, so that camera will follow some point
		 * @param	x - x coordinate of point where camera should 'look'
		 * @param	y - y coordinate of point where camera should 'look'
		 * @param	scale
		 * @param	rotation
		 */
		protected function controlCamera(x:Number, y:Number, scale:Number, rotation:Number):void
		{
			var xDiff:Number = ( _camera.x - x );
			var yDiff:Number = ( _camera.y - y );
			_camera.x = _camera.x - xDiff * 0.25;
			_camera.y = _camera.y - yDiff * 0.25;
			
			var h:Number = _camH * _camera.scaleY;
			var w:Number = _camW * _camera.scaleX;
			
			var matrix:Matrix = _camera.transform.matrix.clone();
			matrix.invert();			
			matrix.translate( w / 2, h / 2 );
			
			//_camera.parent.transform.matrix = matrix;
			
			var mtx23:Mat23 = Mat23.fromMatrix(matrix);
			_debugView.transform = mtx23;
		}
		
		/**
		 * This one should be overridden, contains custom everyframe updates
		 */
		protected function updates():void 
		{}
		
		/**
		 * Callback for event when key is released
		 */
		protected function keyReleased(e:KeyboardEvent):void 
		{
			var index:int = _pressedKeys.indexOf(e.keyCode);
			
			if ( index == -1 )
				return;
			else
				_pressedKeys.splice(index, 1)
				
			if ( e.keyCode == Keyboard.ESCAPE  )
			{
				_escPressed = false;
			}
		}
		
		/**
		 * Callback for event when key is pressed
		 */
		protected function keyPressed(e:KeyboardEvent):void 
		{
			var index:int = _pressedKeys.indexOf(e.keyCode);
			
			if ( index == -1 )
				_pressedKeys.push(e.keyCode)
			
			if ( e.keyCode == Keyboard.ESCAPE && !_escPressed )
			{
				_pause = !_pause;
				_escPressed = true;
			}
		}
		
		/**
		 * Whether key was pressed
		 */
		public function keyIsPressed( keyCode:uint ):Boolean
		{
			return _pressedKeys.indexOf(keyCode) != -1;
		}		
		
		/**
		 * 
		 * @param	e
		 */
		private function middleUnClicked(e:MouseEvent):void 
		{
			_middleClicked = false;
		}
		
		/**
		 * 
		 * @param	e
		 */
		private function middleClicked(e:MouseEvent):void 
		{
			_middleClicked = true;	
		}
		
		/**
		 * Used exclusively for mouse joint
		 * @param	e
		 */
		private function mouseUpHandler(e:MouseEvent):void 
		{
			_mouseJoint.active = false;
		}
		
		/**
		 * Used exclusively for mouse joint
		 * @param	e
		 */
		private function mouseDownHandler(e:MouseEvent):void 
		{
			var bodies:BodyList = _space.bodiesUnderPoint(_mousePoint);
			for ( var i:int = 0; i < bodies.length; i++ )
			{
				var body:Body = bodies.at(i);
				if ( !body.isDynamic() )
					continue;
					
				_mouseJoint.body2 = body;
				_mouseJoint.anchor2.set(body.worldPointToLocal(_mousePoint, true));
				_mouseJoint.active = true;
				
				break;
			}
			
		}
		
		/**
		 * Called automatically when the game sprite is removed from it's parent.
		 * 'Destroys' the game.
		 * @param	e
		 */
		private function destroy(e:Event):void 
		{
			_space.clear();
			_debugView.clear();
			Debug.clearObjectPools();
			stage.removeEventListener(KeyboardEvent.KEY_DOWN, keyPressed);
			stage.removeEventListener(KeyboardEvent.KEY_UP, keyReleased);
			removeEventListener(Event.ENTER_FRAME, update);
			removeEventListener(Event.REMOVED, destroy);
			removeEventListener(MouseEvent.MOUSE_DOWN, mouseDownHandler);
			removeEventListener(MouseEvent.MOUSE_UP, mouseUpHandler);			
			removeEventListener(MouseEvent.MIDDLE_MOUSE_DOWN, middleClicked);
			removeEventListener(MouseEvent.MIDDLE_MOUSE_UP, middleUnClicked);
		}
		
	}

}