part of planner;

/**
 * Protractor class provide visual representation of
 * angle between objects
 */
class Protractor extends MetaCanvasObject
{
	/*
	 * Defaults
	 */
	static const CLASS = 'anchor-protractor';
	
	/*
	 * Data
	 */
	List<ProtractorSector>	_sectors = new List<ProtractorSector>();
	final Anchor			_anchor;
	final Set<Wall>			_walls;
	
	/*
	 * Getters
	 */
	Point get center => this._anchor.center;
	
	/*
	 * Constructor
	 */
	Protractor (Anchor this._anchor, Set<Wall> this._walls)
	{
		this._node.classes.add(CLASS);
		
		this.update();
	}

	/**
	 * Update path element
	 */
	void update ( )
	{
		// Remove prev data
		this._sectors
		..forEach((ProtractorSector sector) =>
									sector.removeNode())
		..clear();
		
		// Sort walls by angle from horizal axis
		List<Wall> walls = this._walls.toList();
		int wallsCount = walls.length;
		
		// Exit if only wall
		if (wallsCount == 1)
		{
			return;
		}
		
		// Make sure walls are placed straight from the point
		walls.forEach((Wall wall) =>
						   (wall.endPoint != this.center) ? wall.reverse() : wall);
		
		// Sort walls in anticlockwise direction
		walls.sort(Wall.compare);
		
		// Sectors protractor
		for (int i = 0; i < wallsCount; i++)
		{
			// Get next and active walls
			Wall nextWall = (i == wallsCount - 1) ? walls.first : walls[i + 1],
				 activeWall = walls[i];
			
			// Get angles of both walls
			Angle startAngle = activeWall.angleFromHorizontalAxis,
				  endAngle = nextWall.angleFromHorizontalAxis;
			
			// Compose sector with flipped end and start angles
			ProtractorSector protractorSector = new ProtractorSector(center, endAngle, startAngle);
			
			// Skip empty sectors
			if (protractorSector.angle == 270 ||
				protractorSector.angle == 180 ||
				protractorSector.angle == 0)
			{
				protractorSector.removeNode();
				
				continue;
			}
			
			this._sectors.add(protractorSector);
			this._node.children.add(protractorSector.node);
		}
	}
}