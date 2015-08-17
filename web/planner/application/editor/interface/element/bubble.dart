part of planner;

/**
 * Context bubble class replaces classic context menu
 */
class ContextBubble extends InterfaceBlock
{
	/*
	 * Defaults
	 */
	static const CLASS			= 'context-bubble',
				 ACTIVE_CLASS	= 'active',
				 MAX_OPTIONS	= 6;
	
	/*
	 * Data
	 */
	List<ContextBubbleOption> _options = new List<ContextBubbleOption>();
	final List<String> _data = [	'M112.502,103.352l-50.01-86.62C25.135,38.346,0,78.736,0,125h100C100,115.748,105.03,107.675,112.502,103.352z',
    		                        'M125,100c4.555,0,8.82,1.224,12.498,3.352l50.012-86.62C169.121,6.093,147.772,0,125,0S80.88,6.092,62.492,16.732l50.01,86.62C116.179,101.224,120.445,100,125,100z',
    		                        'M150,125h100c0-46.263-25.135-86.653-62.49-108.268l-50.012,86.62C144.97,107.675,150,115.748,150,125z',
    		                        'M150,125c0,9.252-5.03,17.324-12.501,21.647l50.01,86.62C224.865,211.653,250,171.263,250,125H150z',
    		                        'M125,150c-4.555,0-8.821-1.225-12.499-3.353l-50.011,86.62C80.878,243.907,102.227,250,125,250c22.772,0,44.12-6.093,62.509-16.732l-50.01-86.62C133.821,148.775,129.555,150,125,150z',
    		                        'M100,125H0c0,46.263,25.134,86.652,62.49,108.268l50.011-86.62C105.03,142.324,100,134.252,100,125z' ];
	
	/*
	 * Constructor
	 */
	ContextBubble (Point center)
	{
		this._node = new Element.html('<menu type="context" class="$CLASS"></menu>');
		
		// Create svg circle
		SvgSvgElement svg = new SvgSvgElement();
		GElement g = new GElement();
		
		svg.children.add(g);
		this._node.children.add(svg);
		
		// Set position
		this._node..style.top = '${center.y - 250 ~/ 2}px'
				  ..style.left = '${center.x - 250 ~/ 2}px';
		
		// Css animation
		new Timer(new Duration(milliseconds: 1), () => this._node.classes.add(ACTIVE_CLASS));
	}
	
	/*
	 * Getters
	 */
	Element get _sectorsNode => this._node.querySelector('svg g');
	
	/**
	 * Registers option
	 */
	void register (ContextBubbleOption option)
	{
		if (this._options.length >= MAX_OPTIONS)
		{
			throw new StateError('Max options achieved');
		}
		
		this._options.add(option);
		
		// Add node
		int index = this._options.length;
		GElement g = new GElement();
		PathElement path = new PathElement();
		TextElement text = new TextElement();
		
		g..classes.add('sector');
        			
		path..attributes['d'] = this._data[index - 1]
			..attributes['id'] = 'sector${index}';
			
		num angle;
		
		if (index == 1)
		{
			angle = 150;
		}
		else if (index == 2)
		{
			angle = 90;
		}
		else if (index == 3)
		{
			angle = 30;
		}
		else if (index == 4)
		{
			angle = 330;
		}
		else if (index == 5)
		{
			angle = 270;
		}
		else
		{
			angle = 210;
		}
		
		angle -= 180;
		
		Point position = new Point(80 * -Math.cos(Angle.deg2rad(angle)),
								   80 * Math.sin(Angle.deg2rad(angle)));
		
		text..innerHtml = '${option.label}'
			..attributes['x'] = '${position.x + 125}'
			..attributes['y'] = '${position.y + 125}';
		
		g.children.add(path);
		g.children.add(text);
		
		this._sectorsNode.children.add(g);
	}
}