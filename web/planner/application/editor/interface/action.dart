part of planner;

/*
 *	Editor action class.
 *	
 *	Each action provide unique function which could
 *	be called at any time. Handles ACTION_CALL event.
 */
class Action
{
	/*
	 * Defaults
	 */
	static const EXECUTE_EVENT = 'onActionExecute';
	
	/*
	 * Data
	 */
	static final Map<String, Action>	_actions		= new Map<String, Action>();
	static StreamSubscription			_hotkeyListener	= window.on[Hotkey.COMBINATION_EVENT].listen(Action._hotkeyHandler);
	final Function						_function;
	final List<int>						_hotkey;
	
	/*
	 * Constructor
	 */
	Action (String actionId, Function this._function, [ List<int> this._hotkey ])
	{
		if (Action._hotkeyListener == null)
		{
			Action._hotkeyListener = window.on[Hotkey.COMBINATION_EVENT].listen(Action._hotkeyHandler);
		}
		
		Action._actions[actionId] = this;
	}
	
	/*
	 * Getters
	 */
	List<int> get hotkey => this._hotkey;
	
	/**
	 * 
	 */
	static Action alias (String actionId) => Action._actions[actionId];
	
	/**
	 * Handles hotkey combination
	 */
	static void _hotkeyHandler (CustomEvent event)
	{
		for (Action action in Action._actions.values)
		{
			if (action.hotkey == null)
			{
				continue;
			}
			
			if (Hotkey.active.containsAll(action.hotkey))
			{
				event.detail['originalEvent'].preventDefault();
				
				action.execute();
				
				break;
			}
		}
	}
	
	/**
	 * Executes action
	 */
	void execute ( )
	{
		Function.apply(this._function, []);
	}
}