part of planner;

/*
 *	Editor canvas class.
 *
 *	Base class for layers and grid. Allows to
 *	enable zooming, panning and rotation(?) on
 *	any svg element using viewbox attribute.
 */
abstract class Canvas extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const WRAP_CLASS		= 'editable-canvas-wrap',
				 CLASS			= 'editable-canvas',
				 CANVAS_CLASS	= 'editable-canvas-data';
	
	/*
	 * Data
	 */
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();
	SvgSvgElement					_svgNode;
	GElement						_gNode;
	
	/*
	 * Constructor
	 */
	Canvas ( )
	{
		// Create node
		this._node		= new Element.html('<div class="$WRAP_CLASS"></div>');
		this._svgNode	= new SvgSvgElement()..classes.add(CLASS);
		this._gNode		= new GElement()..classes.add(CANVAS_CLASS);
		
		this._svgNode.children.add(this._gNode);
		this._node.children.add(this._svgNode);
		
		// Set base
		this.setSize(width: Project.size.width, height: Project.size.height);
		
		// Event listeners
		this._listeners['onZoom'] = window.on[Editor.ZOOM_EVENT].listen(this._zoomHandler);
		
		// Compose
		this._compose();
	}
	
	/*
	 * Getters
	 */
	Element		get _canvas => this._gNode;
	int			get width => int.parse(this._canvas.attributes['height'].replaceAll('px', ''));
	int			get height => int.parse(this._canvas.attributes['height'].replaceAll('px', ''));
	
	/**
	 * Handles zooming
	 */
	void _zoomHandler (CustomEvent event)
	{
		this._canvas.style.transform = 'scale(${event.detail['level'] as double})';
	}
	
	/**
	 * Sets canvas size
	 */
	void setSize ({ int width, int height })
	{
		// If no changes
		if (width	== null &&
			height	== null)
		{
			return;
		}
		
		// Calculate new values
		int newWidth	= (width == null)	? this.width	: width,
			newHeight	= (height == null)	? this.height	: height;
	
		// Set size
		this._svgNode.attributes['width']	= '$newWidth';
		this._svgNode.attributes['height']	= '$newHeight';
	}
}