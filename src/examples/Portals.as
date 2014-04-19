package examples 
{
	/**
	 * ...
	 * @author Hammerzeit
	 */
	import examples.common.Template;
	import nape.callbacks.CbEvent;
	import nape.callbacks.CbType;
	import nape.callbacks.InteractionCallback;
	import nape.callbacks.InteractionListener;
	import nape.callbacks.InteractionType;
	import nape.callbacks.PreCallback;
	import nape.callbacks.PreFlag;
	import nape.callbacks.PreListener;
	import nape.constraint.Constraint;
	import nape.constraint.PivotJoint;
	import nape.constraint.UserConstraint;
	import nape.dynamics.CollisionArbiter;
	import nape.dynamics.Contact;
	import nape.geom.Vec2;
	import nape.geom.Vec3;
	import nape.phys.Body;
	import nape.phys.BodyType;
	import nape.phys.Compound;
	import nape.phys.Material;
	import nape.shape.Circle;
	import nape.shape.Polygon;
	import nape.shape.Shape;
	import nape.shape.ShapeList;
	import nape.space.Space;
	import nape.util.Debug;
	//import nape.TArray;

	public class Portals extends Template 
	{
		function Portals() {
			super({
				gravity : Vec2.get(0, 600)
			});
		}

		var manager:PortalManager;

		override protected function init():void
		{
			var w:Number = stage.stageWidth;
			var h:Number = stage.stageHeight;

			// Add some higher drag to stop things going mental
			space.worldLinearDrag = 0.25;
			space.worldAngularDrag = 0.25;

			// Increase strength of hand to rotate the cascade
			hand.maxForce = 1e6;
			hand.frequency = 20;
			hand.damping = 4;

			manager = new PortalManager(space);

			// Set up cascading mechanic
			var cascade = new Body();
			var portalA:Portal = genPortal(60,  Vec2.get(   0, -160),  Math.PI*0.5, cascade);
			var portalB:Portal = genPortal(60,  Vec2.get(   0,  160), -Math.PI*0.5, cascade);
			var portalC:Portal = genPortal(140, Vec2.get(  40,    0),            0, cascade);
			var portalD:Portal = genPortal(140, Vec2.get( 320,    0),  Math.PI    , cascade);
			var portalE:Portal = genPortal(140, Vec2.get( -40,    0),  Math.PI    , cascade);
			var portalF:Portal = genPortal(140, Vec2.get(-320,    0),            0, cascade);

			// We make each portal symmetric, not actually necessary.
			portalC.target = portalA; portalA.target = portalC;
			portalB.target = portalE; portalE.target = portalB;
			portalD.target = portalF; portalF.target = portalD;

			// Add additional guide shapes.
			cascade.shapes.add(new Polygon(Polygon.rect( -30, -150,  -10,  70)));
			cascade.shapes.add(new Polygon(Polygon.rect( -30,  150,  -10, -70)));
			cascade.shapes.add(new Polygon(Polygon.rect(  30, -150,   10,  70)));
			cascade.shapes.add(new Polygon(Polygon.rect(  30,  150,   10, -70)));
			cascade.shapes.add(new Polygon(Polygon.rect(-310,  -80,  260,  10)));
			cascade.shapes.add(new Polygon(Polygon.rect(-310,   80,  260, -10)));
			cascade.shapes.add(new Polygon(Polygon.rect( 310,  -80, -260,  10)));
			cascade.shapes.add(new Polygon(Polygon.rect( 310,   80, -260, -10)));

			cascade.position.setxy(w/2, h/2);
			cascade.angularVel = 0.25;
			cascade.setShapeMaterials(Material.steel());
			cascade.space = space;

			// Pin cascade to background
			var pivot:PivotJoint = new PivotJoint(space.world, cascade, cascade.position, Vec2.weak());
			pivot.space = space;

			// Add some balls!!!!
			for ( var i:int = 0; i < 6; i++ ) 
			{
				for ( var j:int = 0; j < 3; j++ ) 
				{
					var ball:Body = new Body();
					var radius:int = 15 + i;
					ball.shapes.add(new Circle(radius/2, Vec2.weak(0, -radius/2)));
					ball.shapes.add(new Circle(radius/2, Vec2.weak(0,  radius/2)));
					ball.position.setxy(w/2 - 280 + i * 40, h/2 + (j - 1) * 40);
					ball.space = space;

					// Manager requires PORTABLE CbType to be given to portable shapes.
					ball.shapes.at(0).cbTypes.add(manager.PORTABLE);
					ball.shapes.at(1).cbTypes.add(manager.PORTABLE);

					var ball:Body = new Body();
					ball.shapes.add(new Polygon(Polygon.box(radius*2, radius*2)));
					ball.position.setxy(w/2 + 280 - i * 40, h/2 + (j - 1) * 40);
					ball.space = space;

					// Manager requires PORTABLE CbType to be given to portable shapes.
					ball.shapes.at(0).cbTypes.add(manager.PORTABLE);
				}
			}
		}

		private function genPortal(width:Number, position:Vec2 = null, rotation:Number = 0.0, body:Body = null):Portal 
		{
			if (body == null) body = new Body();
			var sides:Vector.<Shape> = new Vector.<Shape>;
			sides.push(new Polygon(Polygon.rect( -10, -width / 2, 20, -10)));
			sides.push(new Polygon(Polygon.rect(-10,  width/2, 20,  10)));
			var back:Polygon = new Polygon(Polygon.rect(-10, -width/2, 5, width));

			sides[0].rotate(rotation);
			sides[1].rotate(rotation);
			back.rotate(rotation);
			if (position != null) {
				sides[0].translate(position);
				sides[1].translate(position);
				back.translate(position);
			}

			sides[0].body = body;
			sides[1].body = body;
			back.body = body;

			var sensor:Polygon = new Polygon(Polygon.rect(-5, -width/2, 15, width));
			sensor.rotate(rotation);
			if (position != null) {
				sensor.translate(position);
			}
			sensor.sensorEnabled = true;
			sensor.cbTypes.add(manager.PORTAL);
			sensor.body = body;

			var portal:Portal =  new Portal();
			portal.target = null;
			portal.collide =  sides;
			portal.ignore = new Vector.<Shape>;
			portal.ignore.push(back);

			portal.body = body;
			portal.sensor = sensor;
			portal.position = Vec2.get(0, 0).rotate(rotation).addeq(position);
			portal.direction = Vec2.fromPolar(1, rotation);
			portal.width = width;
			

			var sensorData:PortalSensorData = sensor.userData;
			sensorData.__portal = portal;

			return portal;
		}

		//static function main() {
			//addChild(new Portals());
		//}
	}
}

import adobe.utils.CustomActions;
import nape.callbacks.CbEvent;
import nape.callbacks.CbType;
import nape.callbacks.InteractionCallback;
import nape.callbacks.InteractionListener;
import nape.callbacks.InteractionType;
import nape.callbacks.PreCallback;
import nape.callbacks.PreFlag;
import nape.callbacks.PreListener;
import nape.constraint.UserConstraint;
import nape.dynamics.CollisionArbiter;
import nape.geom.Vec2;
import nape.geom.Vec3;
import nape.phys.Body;
import nape.shape.Shape;
import nape.shape.ShapeList;
import nape.space.Space;
import nape.util.Debug;
// This should be moved to a new file, but I felt it was important for
// the sample logic to be shown in full.

// This manager does not try to work with constraints, and will quite simply
// fail when constraints are attempted to be 'passed' through a portal.
//
// This system works by; when a shape intersects the source portal, constructing
// a partial clone of the body on the other side; linked by a PortalConstraint
// as more shapes pass thorugh the portal of the same body those are then duplicated
// on the other side. Once a shape has exited both source and target it is removed
// from the appropriate side.
//
// Once a shape enters the source portal, it is excluded from collisions with anything
// in the half-space behind the portal, equally the cloned shape is excluded from
// colisions with anything behind its source portal. This persists until it exits
// the relevant portal.
//
// When multiple portals can be involved, this is made more complex. We must ensure
// that in a chain of portal interactions of a single body, that we do not introduce
// a 'cut' into the chain prematurely. This is only possible due to portal sensors
// not being infinitesemally thin, but we cannot have that for other reasons.

class Portal  
{
	public var target:Portal; // where entering this portal takes you
	public var collide : Vector.<Shape>; // shapes to always collide with belonging to portal when passing through
	public var ignore : Vector.<Shape>; // shapes to never collide with belonging to portal whe passing through

	public var body : Body;
	public var sensor : Shape;
	public var position : Vec2; // position of portal centre (local to body)
	public var direction : Vec2; // direction of portal (local to body)
	public var width : Number; // width of portal
}

// Could be moved to a class for better run-time performance in AVM2.
class PortalPair
{
	public var portalA: Portal;
	public var portalB: Portal;
	public var bodyA: Body;
	public var bodyB: Body;
}

// Typedefs for structual typing of Body/Shape's userData fields
// and improve runtime performance through better typing.
class  PortableBodyData 
{
	public var __portal_pairs : Vector.<PortalPair>;
}
class  PortalShapeData 
{
	public var portal : Portal;
	public var portal_target : Boolean;
}
class  PortableShapeData 
{
	public var __portal_id : int;
	public var __portals : Vector.<PortalShapeData>;
	public var __portal_active : int;
}

class  PortalSensorData
{
	public var __portal : Portal;
}

class PortalManager 
{

	// CbType for a portal sensor Shape
	public var PORTAL:CbType;

	// CbType for a Shape that is permitted to pass through portals.
	public var PORTABLE:CbType;

	// CbType for a Shape which is intersecting a portal sensor.
	public var PARTIAL:CbType;

	var portalID:int = 0;

	public function PortalManager(space:Space) 
	{
		PORTAL = new CbType();
		PORTABLE = new CbType();
		PARTIAL = new CbType();

		space.listeners.add(new InteractionListener(
			CbEvent.BEGIN,
			InteractionType.SENSOR,
			PORTAL,
			PORTABLE,
			portalBegin
		));

		space.listeners.add(new InteractionListener(
			CbEvent.END,
			InteractionType.SENSOR,
			PORTAL,
			PORTABLE,
			portalEnd
		));

		space.listeners.add(new PreListener(
			InteractionType.COLLISION,
			PARTIAL,
			CbType.ANY_SHAPE,
			backCollision
		));
	}

	function portalBegin(cb:InteractionCallback) 
	{
		var portalSensor:Shape = cb.int1.castShape;
		var shape:Shape = cb.int2.castShape;
		var body:Body = shape.body;

		// Can happen in rare circumstances where an END is processed before the BEGIN occurs with CCD
		if (body == null) {
			return;
		}

		var portalData:PortalSensorData =  portalSensor.userData;
		var shapeData:PortableShapeData =  shape.userData;
		var bodyData:PortableBodyData =  body.userData;
		var portal:Portal = portalData.__portal;

		// Cases to consider:
		//
		// Either this shape is already interacting via this portal
		// (Still has a cloned shape on otherside) and has started to
		// overlap again on other side.
		//
		// This shape has just started interacting via the portal and:
		//    This is the first shape of the body to interact
		//    The body is already interacting via this portal.
		//
		// Also possible for shape which has passed through back of portal
		// sensor, to then intersect the target portal sensor before exiting
		// and must be ignored.
		//
		// A further fucking case occurs when we have portals very close together
		// and we can have portals arrange like || || with a body passing from left
		// to right, at the point where the body (partially passed through first two)
		// started intersecting the next portal in the line, then moves backwards.
		// the cloned body from second set of portals then enters 'back' into the first
		// set. We want to treat this as one continuous 'chain' and not permit such
		// back portalling. (#). We cannot however permit cyclic portalling.

		// Search for existing PortalPair for this (portal,body) pair
		var portalPair:PortalPair = null;
		if (bodyData.__portal_pairs != null) {
			for each ( var pair:PortalPair in bodyData.__portal_pairs) 
			{
				if ((pair.portalA == portal || pair.portalB == portal)
				 && (pair.bodyA == body || pair.bodyB == body)) {
					portalPair = pair;
					break;
				}
			}
		}

		// Ensure we're not entering a portal that is behind one we're currently going through.
		//
		// Bug (deficiency): Really need to test with the shape-[portal sensor] contact points
		// (which do not exist, we're using sensor) to get an accurate flag here instead of using
		// portal.sensor.worldCOM. Either need to change portal sensors to colliders with
		// appropriate PreListener to always ignore interaction, or perhaps use Geom.distance
		if (portalPair == null && shapeData.__portal_id != undefined && shape.cbTypes.has(PARTIAL)) {
			for each ( var portalData1:PortalShapeData in shapeData.__portals) 
			{
				if (behindPortal(portalData1.portal, portal.sensor.worldCOM)) {
					return;
				}
			}
		}

		var targetPortal:Portal = portal.target;
		var scale:Number = targetPortal.width / portal.width;
		if (portalPair == null) {
			// Check we don't have case (#)
			if (bodyData.__portal_pairs != null) {
				var stack:Array = [body];
				var visited:Array = [body];
				var longChain:Boolean = false;
				while (stack.length > 0 && !longChain) {
					var body:Body = stack.pop();
					var bodyData:PortableBodyData =  body.userData;
					for each ( var pair:PortalPair in bodyData.__portal_pairs) {
						var otherBody:Body = (pair.bodyA == body) ? pair.bodyB : pair.bodyA;
						if (visited.indexOf( otherBody) == -1) {
							visited.push(otherBody);
							stack.push(otherBody);
						}

						if (pair.portalA == portal || pair.portalB == portal) {
							longChain = true;
							break;
						}
					}
				}

				if (longChain) {
					return;
				}
			}


			// This is a brand new interaction between this body and portal.

			// Create cloned body with initial cloned shape.
			var clone:Body = new Body();
			var cloneShape:Shape = shape.copy();
			cloneShape.scale(scale, scale);
			cloneShape.body = clone;
			clone.space = body.space;

			// Create portal constraint.
			var pcon = new PortalConstraint(
				portal.body,       portal.position,       portal.direction,
				targetPortal.body, targetPortal.position, targetPortal.direction,
				scale, body, clone
			);
			pcon.space = clone.space;

			// Set properties of clone to satisfy constraint.
			pcon.setProperties(clone, body);

			// Create portal pair.
			portalPair = new PortalPair();				
			portalPair.portalA = portal,
			portalPair.portalB = targetPortal,
			portalPair.bodyA = body,
			portalPair.bodyB = clone
			

			// Assign to pair lists.
			if (bodyData.__portal_pairs == null) {
				bodyData.__portal_pairs = new Vector.<PortalPair>;
			}
			bodyData.__portal_pairs.push(portalPair);
			var cloneData:PortableBodyData =  clone.userData as PortableBodyData;
			cloneData.__portal_pairs = new Vector.<PortalPair>;
			cloneData.__portal_pairs.push(portalPair);

			// Assign id if not existing.
			var id = shapeData.__portal_id;
			var portals = shapeData.__portals;
			if (id == null) {
				id = shapeData.__portal_id = portalID++;
				portals = shapeData.__portals = new Vector.<PortalShapeData>;
				shapeData.__portal_active = 0;
			}
			var psh:PortalShapeData = new PortalShapeData();
			psh.portal = portal;
			psh.portal_target = false;
			portals.push(psh);
			shapeData.__portal_active++;

			var cloneShapeData:PortableShapeData =  cloneShape.userData;
			cloneShapeData.__portal_id = id;
			var psh:PortalShapeData = new PortalShapeData();
			psh.portal = portal.target;
			psh.portal_target = true;
			cloneShapeData.__portals = new Vector.<PortalShapeData>;
			cloneShapeData.__portals.push(psh);
			cloneShapeData.__portal_active = 0;

			// Add PARTIAL CbTypes if it is not already present.
			if (!shape.cbTypes.has(PARTIAL)) {
				shape.cbTypes.add(PARTIAL);
				cloneShape.cbTypes.add(PARTIAL);
			}
		}
		else {
			// Portal interaction exists for this body and portal.

			// Check shape, passed through front is not now just intersecting back
			// (Occurs if portals placed very close together into eachother)
			//
			// Also need to check that if shape pair exists, then at least one of
			// the portals is the same to avoid incrementing count. Can occur if
			// if the portals are not symmetric.
			var anyEqual = false;
			if (shapeData.__portals != null) {
				for each ( var portalData1:PortalShapeData in shapeData.__portals) {
					if (portalData1.portal.target == portal) {
						return;
					}
					if (portalData1.portal == portal) {
						anyEqual = true;
					}
				}
			}

			// Check to see if Shape is already part of the interaction.

			var clone:Body =  (portalPair.bodyA == body) ? portalPair.bodyB : portalPair.bodyA;
			var found = false;
			if (shapeData.__portal_id != undefined) {
				for each ( var cloneShape1:Shape in clone.shapes) {
					var cloneShapeData:PortableShapeData =  cloneShape1.userData as PortableShapeData;
					if (cloneShapeData.__portal_id == shapeData.__portal_id) {
						found = true;
						break;
					}
				}
			}

			if (!found) {

				// Shape is not part of the interaction, create its clone.
				var cloneShape = shape.copy();
				cloneShape.scale(scale, scale);
				cloneShape.body = clone;

				if (shapeData.__portal_id == undefined) {
					shapeData.__portal_id = portalID++;
					shapeData.__portals = new Vector.<PortalShapeData>;
					shapeData.__portal_active = 0;
				}

				shapeData.__portals.push({
					portal : portal,
					portal_target : false
				});
				shapeData.__portal_active++;

				var cloneShapeData:PortableShapeData =  cloneShape.userData as PortableShapeData;
				cloneShapeData.__portal_id = shapeData.__portal_id;
				cloneShapeData.__portals = new Vector.<PortalShapeData>;
				var psh1:PortalShapeData = new PortalShapeData();
				psh1.portal = portal.target;
				psh1.portal_target = true;
				cloneShapeData.__portals.push(psh1);
				
				cloneShapeData.__portal_active = 0;

				// Add PARTIAL CbTypes if it is not already present.
				if (!shape.cbTypes.has(PARTIAL)) {
					shape.cbTypes.add(PARTIAL);
					cloneShape.cbTypes.add(PARTIAL);
				}
			}
			else if (anyEqual) {
				shapeData.__portal_active++;
			}
		}
	}

	function portalEnd(cb:InteractionCallback) {
		var portalSensor:Shape = cb.int1.castShape;
		var shape:Shape = cb.int2.castShape;
		var body:Body = shape.body;

		// Can occur when an object has entered portal, then intersects
		// target portal before exiting.
		//
		// The final clean up of shapes can leave some such dangling cases.
		if (body == null) {
			return;
		}

		var portalData:PortalSensorData =  portalSensor.userData;
		var shapeData:PortableShapeData =  shape.userData;
		var bodyData:PortableBodyData =  body.userData;
		var portal:Portal = portalData.__portal;

		// Two main cases to consider:
		//    The shape has exited the portal sensor from the front
		//    and we keep it in its current body
		//
		//    Or the shape has exited through the back and should be
		//    completely teleported to other side.
		//
		// This is complicated with multiple portals as we must
		// ensure we do not introduce 'cuts' in the portal chains
		// and so we choose the simpler option: Remove the shape
		// only when this is the 'last' 'exit' in the chain for
		// the shape.
		//
		// We use the userData field __portal_active to track this
		// and for robustneed compute which side the shape should move
		// to at this point, storing it in __portal_target boolean
		// (true) if shape is moved to target side of portal pair.

		var portals:Vector.<PortalShapeData> = shapeData.__portals;
		portalData = null;
		for each ( var pData:PortalShapeData in portals) {
			if (pData.portal == portal) {
				portalData = pData;
				break;
			}
		}

		if (portalData == null) {
			// can occur if object enters portal, then intersects target portal
			// too. We ignore this in begin interaction
			// and we ignore it in end too.
			return;
		}

		// Just exited portal sensor, no longer active in chain.
		shapeData.__portal_active--;
		portalData.portal_target = behindPortal(portal, shape.worldCOM);

		// Get list of all shapes in the portal chain.
		var shapes:Array = [shape];
		var stack:Array = [body];
		while (stack.length > 0) {
			var stackBody:Body = stack.pop();
			var stackData:PortableBodyData = stackBody.userData;
			for each (var pair:PortalPair in stackData.__portal_pairs) {
				var clone:Body =  (pair.bodyA == stackBody) ? pair.bodyB : pair.bodyA;
				for each(var cloneShape in clone.shapes) {
					var cloneShapeData:PortableShapeData =  cloneShape.userData;
					// Possible new shape in chain.
					var sData:PortableShapeData =  cloneShape.userData;
					if (sData.__portal_active != null) {
						if (shapes.indexOf(cloneShape) == -1) {
							shapes.push(cloneShape);
							stack.push(cloneShape.body);
						}
					}
				}
			}
		}

		// Check whether all shapes in chain are inactive.
		var anyActive = false;
		for each ( var s:Shape in shapes) {
			var sData:PortableShapeData = s.userData;
			if (sData.__portal_active != 0) {
				anyActive = true;
				break;
			}
		}

		// Nothing to do yet.
		if (anyActive) {
			return;
		}

		// All shapes are inactive.
		// We now proceed to remove all but 1 of the shapes in the chain
		// The remaining shape being the final destination of the portal chain.
		var survivors:Array = [];
		for each ( var shape:Shape in shapes) 
		{
			var sData:PortableShapeData =  shape.userData;

			var anyTarget:Boolean = false;
			for each( var portalData1:PortalShapeData in sData.__portals) {
				if (portalData1.portal_target) {
					anyTarget = true;
					break;
				}
			}

			if (anyTarget) {
				var body:Body = shape.body;
				shape.body = null;
				if (body.shapes.empty()) {
					// disable any constraint using body we're about to destroy.
					for each ( var c:Constraint in body.constraints) {
						c.active = false;
					}
					body.space = null;
				}
			}
			else {
				// Shape survives to portal another data.
				survivors.push(shape);
			}
		}


		for each  ( var survivor:* in survivors) {
			var survivorData:PortableShapeData =  survivor.userData;
			survivorData.__portal_id = null;
			survivorData.__portals = [];
			survivor.cbTypes.remove(PARTIAL);

			// Cull any dangling portal pairs.
			var survivorBody:Body = survivor.body;
			var bodyData:PortableBodyData =  survivorBody.userData;
			var i = 0;
			while (i < bodyData.__portal_pairs.length) {
				var pair:PortalPair = bodyData.__portal_pairs[i];
				var clone:Body = (pair.bodyA == survivorBody) ? pair.bodyB : pair.bodyA;
				if (clone.space == null) {
					// pair should be culled.
					bodyData.__portal_pairs.splice(i, 1);
				}
				else {
					i++;
				}
			}
		}
	}

	// Return true if position in world space is behind the given portal.
	function behindPortal(portal:Portal, position:Vec2):Boolean {
		var u:Vec2 = position.sub(portal.body.localPointToWorld(portal.position, true));
		var v:Vec2 = portal.body.localVectorToWorld(portal.direction);
		var behind:Number = u.dot(v) <= 0;
		u.dispose();
		v.dispose();
		return behind;
	}

	// Cull any contacts of collision arbiter
	// that are behind the portal corresponding to the given PARTIAL shape.
	function handlePartial(partial:Shape, carb:CollisionArbiter, ret:PreFlag):PreFlag {
		var partialData:PortableShapeData = partial.userData;
		var portals:Vector.<PortalShapeData> = partialData.__portals;
		for each( var portalData:PortalShapeData in portals) {
			var portal:Portal = portalData.portal;

			var anyBehind:Boolean = false;

			var i:int = 0;
			while (i < carb.contacts.length) {
				var contact:Contact = carb.contacts.at(i);
				var scale:Shape = partial == carb.shape1 ? 0.5 : -0.5;
				var pos:Vec2 = contact.position.addMul(carb.normal, contact.penetration*scale);
				if (behindPortal(portal, pos)) {
					carb.contacts.remove(contact);
					anyBehind = true;
				}
				else {
					i++;
				}
				pos.dispose();
			}

			// If there are any contact points behind,
			// we also cull any virtual ones that may cause issues.
			// We don't simply clear as we do want non-virtual ones.
			if (anyBehind) {
				var i = 0;
				while (i < carb.contacts.length) {
					var contact:Contact = carb.contacts.at(i);
					if (contact.penetration < 0) {
						carb.contacts.remove(contact);
					}
					else {
						i++;
					}
				}
			}

			if (carb.contacts.empty()) {
				return PreFlag.IGNORE_ONCE;
			}
		}

		return ret;
	}

	function backCollision(cb:PreCallback):*
	{
		var partial:Shape = cb.int1.castShape;
		var other:Shape = cb.int2.castShape;
		var carb:CollisionArbiter = cb.arbiter.collisionArbiter;

		var partialData:PortableShapeData =  partial.userData;
		var portals:Vector.<PortalShapeData> = partialData.__portals;
		for each ( var portalData:PortalShapeData in portals) {
			var portal:Portal = portalData.portal;

			// Special case for the portal sides and back.
			// We always permit collision with the portal sides
			// and never with the portal back.
			if (other.body == portal.body) {
				if (portal.collide.indexOf(other) != -1) {
					return PreFlag.ACCEPT_ONCE;
				}
				else if (portal.ignore.indexOf( other) != -1) {
					return PreFlag.IGNORE_ONCE;
				}
			}
		}

		var ret:PreFlag = PreFlag.ACCEPT_ONCE;
		ret = handlePartial(partial, carb, ret);
		if (other.cbTypes.has(PARTIAL)) {
			ret = handlePartial(other, carb, ret);
		}
		return ret;
	}

}

/*
	Constraint for use in portal physics.

	A body and it's clone are linked via this constraint to act as a single
	entitity

	The portals are defined relative to two further bodies which are not
	themselves effect by the constraint. These bodies must be part of
	the constraint so that changes to them may 'wake' the constraint.

	The constraint is kind of like a crazy weldJoint of sorts :P

	Constraint is written to use object pools in all places to avoid
	thrashing GC with Vec2 invocations, but without resorting to hand
	writing all vector operations as speed is not critical here.
*/

/*
	Bodies b1,b2 and Portal bodies pb1,pb2
	Portal local positions lp1,lp2 and directions ld1,ld2
	Portal scaling λ

	To enact that portal bodies are not effected by constraint
	We give them implicit infinite mass.

	Velocity independent values:
		pi = pbi.localVectorToWorld(lpi)
		ni = pbi.localVectorToWorld(ldi)
		si = bi.position - pi - pbi.position
		ai = ldi.angle + pbi.rotation

	Velocity dependent values:
		ui = bi.velocity - pbi.angvel×pi - pbi.velocity

	Positional constraint:
		[              λ·s1·n1 + s2·n2            ]
		[              λ·s1×n1 + s2×n2            ]
		[ (b1.rotation-a1) - (b2.rotation-a2) - π ]

	Velocity constraint:
		[ λ·(u1·n1 + pb1.angvel·s1×n1) + (u2·n2 + pb2.angvel·s2×n2) ]
		[ λ·(u1×n1 + pb1.angvel·s1·n1) + (u2×n2 + pb2.angvel·s2·n2) ]
		[    (b1.angvel - pb1.angvel) - (b2.angvel - pb2.angvel)    ]

	Jacobian (assuming b1,b2,pb1,pb2 ordering):
		[ [ λn1.x  λn1.y 0 ]  [ n2.x  n2.y 0 ]       ]  # doesn't matter
		[ [ λn1.y -λn1.x 0 ], [ n2.y -n2.x 0 ], #, # ]    since we give
		[ [   0      0   1 ]  [  0     0  -1 ]       ]    infinite mass

	Eff-Mass matrix:
	[ λ²/b1.mass + 1/b2.mass          0                        0              ]
	[           0           λ²/b1.mass + 1/b2.mass             0              ]
	[           0                     0           1/b1.inertia + 1/b2.inertia ]

*/

class PortalConstraint extends UserConstraint {
	
	/*public function PortalConstraint(body:Body, position:Vec2, direction:Vec2, body1:Body, position1:Vec2, direction1:Vec2, scale:Number, body2:Body, clone:Body) 
	{
		body1
	}*/

	public var body1:Body;
	public var body2:Body;
	public var portalBody1:Body;
	public var portalBody2:Body;

	/*
		Portal positions+directions defined locally to each portalBody
	*/
	public var position1:Vec2;
	public var position2:Vec2;
	public var direction1:Vec2;
	public var direction2:Vec2;

	/*
		Portal scaling from portal1 to portal2
	*/
	public var scale:Number;

	//---------------------------------------------------------------------------

	function set_body1(body1:Body) {
		return this.body1 = __registerBody(this.body1,body1);
	}
	function set_body2(body2:Body) {
		return this.body2 = __registerBody(this.body2,body2);
	}

	function set_portalBody1(portalBody1:Body) {
		return this.portalBody1 = __registerBody(this.portalBody1,portalBody1);
	}
	function set_portalBody2(portalBody2:Body) {
		return this.portalBody2 = __registerBody(this.portalBody2,portalBody2);
	}

	function set_position1(position1:Vec2) {
		if (this.position1 == null) this.position1 = __bindVec2();
		return this.position1.set(position1);
	}
	function set_position2(position2:Vec2) {
		if (this.position2 == null) this.position2 = __bindVec2();
		return this.position2.set(position2);
	}

	function set_direction1(direction1:Vec2) {
		if (this.direction1 == null) this.direction1 = __bindVec2();
		return this.direction1.set(direction1);
	}
	function set_direction2(direction2:Vec2) {
		if (this.direction2 == null) this.direction2 = __bindVec2();
		return this.direction2.set(direction2);
	}

	function set_scale(scale:Number) {
		if(this.scale!=scale) __invalidate();
		return this.scale = scale;
	}

	//---------------------------------------------------------------------------

	public function PortalConstraint(portalBody1:Body, position1:Vec2, direction1:Vec2,
						portalBody2:Body, position2:Vec2, direction2:Vec2,
						scale:Number, body1:Body, body2:Body)
	{
		super(3); //3 dimensional constraint

		this.portalBody1 = portalBody1; this.portalBody2 = portalBody2;
		this.position1   = position1;   this.position2   = position2;
		this.direction1  = direction1;  this.direction2  = direction2;
		this.scale = scale;
		this.body1 = body1;
		this.body2 = body2;

		//init Vec2's that are reused across methods
		unit_dir1 = Vec2.get();
		unit_dir2 = Vec2.get();

		p1 = Vec2.get(); p2 = Vec2.get();
		s1 = Vec2.get(); s2 = Vec2.get();
		n1 = Vec2.get(); n2 = Vec2.get();
	}

	public override function __copy():UserConstraint {
		return new PortalConstraint(portalBody1, position1, direction1,
									portalBody2, position2, direction2,
									scale, body1, body2);
	}

	//---------------------------------------------------------------------------

	/*
		Method to be used in setting properties of a new clone so that the
		PortalConstraint will be in an already solved state, aka. set up clone to
		be perfectly in place already!
	*/
	public function setProperties(clone:Body, original:Body):void {
		//ensure our required pre-calced values are correct.
		__validate();
		__prepare();

		//compute velocity error so we can set velocity correctly.
		var v = new Vector.<Number>();
		__velocity(v);

		//modify clone so that position and velocity errors are 0
		if (clone == body2) {
			clone.position = portalBody2.position.add(p2,true);
			clone.position.x -= (n2.x * s1.dot(n1) + n2.y * s1.cross(n1))*scale;
			clone.position.y -= (n2.y * s1.dot(n1) - n2.x * s1.cross(n1))*scale;
			clone.rotation = -Math.PI + original.rotation - a1 + a2;

			clone.velocity.x -= n2.x * v[0] + n2.y * v[1];
			clone.velocity.y -= n2.y * v[0] - n2.x * v[1];
			clone.angularVel += v[2];
		}
		else {
			clone.position = portalBody1.position.add(p1, true);
			clone.position.x -= (n1.x * s2.dot(n2) + n1.y * s2.cross(n2))/scale;
			clone.position.y -= (n1.y * s2.dot(n2) - n1.x * s2.cross(n2))/scale;
			clone.rotation = Math.PI + original.rotation - a2 + a1;

			clone.velocity.x += (n1.x * v[0] + n1.y * v[1]) / scale;
			clone.velocity.y += (n1.y * v[0] - n1.x * v[1]) / scale;
			clone.angularVel += v[2];
		}
	}

	//---------------------------------------------------------------------------

	var unit_dir1:Vec2; var unit_dir2:Vec2;
	public override function __validate() {
		unit_dir1.set(direction1.mul(1/direction1.length, true));
		unit_dir2.set(direction2.mul(1/direction2.length, true));
	}

	var p1:Vec2;  var p2:Vec2;
	var s1:Vec2;  var s2:Vec2;
	var n1:Vec2;  var n2:Vec2;
	var a1:Number; var a2:Number;
	public override function __prepare() {
		p1.set(portalBody1.localVectorToWorld(position1, true));
		p2.set(portalBody2.localVectorToWorld(position2, true));

		s1.set(body1.position.sub(p1,true).subeq(portalBody1.position));
		s2.set(body2.position.sub(p2,true).subeq(portalBody2.position));

		n1.set(portalBody1.localVectorToWorld(unit_dir1, true));
		n2.set(portalBody2.localVectorToWorld(unit_dir2, true));

		a1 = unit_dir1.angle + portalBody1.rotation;
		a2 = unit_dir2.angle + portalBody2.rotation;
	}

	public override function __position(err:Vector.<Number>) {
		err[0] = scale*s1.dot  (n1) + s2.dot  (n2);
		err[1] = scale*s1.cross(n1) + s2.cross(n2);
		err[2] = (body1.rotation - a1) - (body2.rotation - a2) - Math.PI;
	}

	public override function __velocity(err:Vector.<Number>) {
		var v1 = body1.constraintVelocity;
		var v2 = body2.constraintVelocity;
		var pv1 = portalBody1.constraintVelocity;
		var pv2 = portalBody2.constraintVelocity;

		var u1 = v1.xy().subeq(p1.perp(true).muleq(pv1.z)).subeq(pv1.xy(true));
		var u2 = v2.xy().subeq(p2.perp(true).muleq(pv2.z)).subeq(pv2.xy(true));

		err[0] = scale*(u1.dot  (n1) + pv1.z*s1.cross(n1))
					 + (u2.dot  (n2) + pv2.z*s2.cross(n2));
		err[1] = scale*(u1.cross(n1) + pv1.z*s1.dot  (n1))
					 + (u2.cross(n2) + pv2.z*s2.dot  (n2));
		err[2] = (v1.z - pv1.z) - (v2.z - pv2.z);

		u1.dispose();
		u2.dispose();
	}

	public override function __eff_mass(eff:Vector.<Number>) {
		eff[0]=eff[3]=body1.constraintMass*scale*scale + body2.constraintMass;
		eff[1]=eff[2]=eff[4] = 0.0;
		eff[5]= body1.constraintInertia + body2.constraintInertia;
	}

	public override function __impulse(imp:Vector.<Number>, body:Body,out:Vec3) {
		if(body==portalBody1 || body==portalBody2) out.setxyz(0,0,0);
		else {
			var sc1, sc2, norm;
			if(body==body1) { sc1 = scale; sc2 =  1.0; norm = n1; }
			else            { sc1 = 1.0;   sc2 = -1.0; norm = n2; }
			out.x = sc1*(norm.x*imp[0] + norm.y*imp[1]);
			out.y = sc1*(norm.y*imp[0] - norm.x*imp[1]);
			out.z = sc2*imp[2];
		}
	}

	//---------------------------------------------------------------------------

	public override function __draw(debug:Debug) {
		__validate();
		var p1 = portalBody1.localPointToWorld(position1);
		var p2 = portalBody2.localPointToWorld(position2);

		debug.drawCircle(p1,2,0xff);
		debug.drawCircle(p2,2,0xff0000);
		debug.drawLine(p1,p1.add(portalBody1.localVectorToWorld(unit_dir1,true).muleq(20),true),0xff);
		debug.drawLine(p2,p2.add(portalBody2.localVectorToWorld(unit_dir2,true).muleq(20),true),0xff0000);
		debug.drawLine(p1,body1.position,0xffff);
		debug.drawLine(p2,body2.position,0xff00ff);

		p1.dispose();
		p2.dispose();
	}
}