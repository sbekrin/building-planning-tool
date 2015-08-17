part of planner;

/**
 *	Custom number input class
 */
class NumberInput extends InterfaceElement
{
	/*
	 * Defaults
	 */
	static const CLASS				= 'gui-input-number',
				 DEFAULT_VALUE		= 0.0;
	
	/*
	 * Data
	 */
	@override SpanElement _node;
	
	/*
	 * Constructor
	 */
	NumberInput ({ num base, num min, num max, num step, String units })
	{
		this._node = new SpanElement()..children.add(new NumberInputElement());
		this._node.classes.add(CLASS);
		
		this.value = (base == null) ? DEFAULT_VALUE : Math.max(base, min);
		
		if (min != null)
		{
			this._inputNode.min = '$min';
		}
		
		if (max != null)
		{
			this._inputNode.max = '$max';
		}
		
		if (step != null)
		{
			this._inputNode.step = '$step';
		}
		
		if (units != null)
		{
			this._node.children.add(new SpanElement()..innerHtml = '&nbsp;$units');
		}
		
		this._compose();
	}
	
	/*
	 * Getters 
	 */
	NumberInputElement get _inputNode => this._node.querySelector('input');
	num get value => this._inputNode.valueAsNumber;
	
	/*
	 * Setters
	 */
	set value (num value) => this._inputNode.value = '$value';
}