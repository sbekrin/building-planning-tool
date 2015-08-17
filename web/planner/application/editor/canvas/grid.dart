part of planner;

/**
 * Grid class provides visual sense of proportion
 */
class Grid extends Canvas implements ISnapable
{
	/*
	 * Dafaults
	 */
	static const DEFAULT_SIZE	= 0.5,
				 ID				= 'grid',
				 PATTERN_ID		= 'GlobalGridPattern',
				 RECT_ID		= 'GlobalGridRect';
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription> _listeners = new Map<String, StreamSubscription>();
	
	/*
	 * Constructor
	 */
	Grid ([ num size = DEFAULT_SIZE ])
	{
		size *= Editor.PIXELS_PER_METER;
		
		// Create line elements
		PolygonElement vline = (new PolygonElement())..attributes['points'] = '0,0 0,$size 1,$size 1,0'
													 ..classes.add('line');
		
		PolygonElement hline = (new PolygonElement())..attributes['points'] = '0,0 $size,0 $size,1 0,1'
													 ..classes.add('line');
		
		// Create pattern element
		PatternElement pattern = (new PatternElement())..id = PATTERN_ID
	  												   ..attributes['width'] = '$size'
													   ..attributes['height'] = '$size'
													   ..attributes['patternUnits'] = 'userSpaceOnUse'
													   ..children.add(vline)
													   ..children.add(hline);
		
		// Create main rectangle
		RectElement rect = new RectElement()..id = RECT_ID
											..attributes['fill'] = 'url(#$PATTERN_ID)'
											..attributes['width'] = '${Project.size.width}'
											..attributes['height'] = '${Project.size.height}'
											..attributes['x'] = '0'
											..attributes['y'] = '0';
		
		// Add rect to svg node
		this._canvas..id = ID
					 //..classes.add(CLASS) // TODO: Issue https:http://www.buildwithchrome.com/buildacademy//code.google.com/p/dart/issues/detail?id=15787
					 ..children.add(rect)
					 ..children.add(new DefsElement()..children.add(pattern));
	}
	
	/*
	 * Getters
	 */
	Element get _rect => querySelector('#$RECT_ID');
	
	/**
	 * 
	 */
	bool isSnapPoint (Point point)
	{
		return false;
	}
	
	/**
	 * 
	 */
	Point getSnapPoint (Point point)
	{
		return new Point(0, 0);
	}
}