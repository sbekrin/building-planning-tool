part of planner;

/*
 *	Editor tool class.
 *
 *	Every object of that class should be unique
 *	item and used only for semantic separation.
 *	Any special action, which require exact
 *	tool should check active tool itself throw
 *	"Tool.active". Triggers custom event on
 *	editor container when tool being changed.
 *	Id attribute should be the same for both
 *	tool and icon.
 */
class Tool //extends IconButton
{
	/*
	 * Defaults
	 */
	static const CHANGE_EVENT	= 'onToolChange',
				 MOVE			= 'move-tool',
				 SELECT			= 'select-tool',
				 WALL			= 'draw-tool',
				 FLOOR			= 'floor-tool';
	
	/*
	 * Data
	 */
	static String active = Tool.SELECT;
	
	int								_hotkey;
	IconButton						_button;
	Map<String, StreamSubscription>	_listeners	= new Map<String, StreamSubscription>();

	/*
	 * Constructor
	 */
	Tool (String toolId, String title, int hotkey)
	{
		this._button = new IconButton(new Icon(toolId),
									  new Action('swtichTo${toolId}Tool', this.setActive, [ hotkey ]),
									  //tooltip: '$title (${Key.get(hotkey).shortcut})');
									  tooltip: '$title');
		this._button.id = toolId;
		this._hotkey = hotkey;
		
		this._listeners['onClick']	= this._button.on['click'].listen(this._clickHandler);
	}
	
	/*
	 * Getters
	 */
	int		get hotkey	=> this._hotkey;
	Button	get button	=> this._button;
	String	get id		=> this._button.id;
	
	/**
	 * Handles mouse click
	 */
	void _clickHandler (MouseEvent event)
	{
		this.setActive();
	}
	
	/**
	 * Activates tool
	 */
	void setActive ( )
	{
		if (Tool.active != this.id)
		{
			window.dispatchEvent(new CustomEvent(CHANGE_EVENT, detail: { 'id': this.id  }));
		}
	}
	
	/**
	 * Click alias
	 */
	void click ( ) => this._button.click();
}