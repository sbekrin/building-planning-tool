part of planner;

class MenuSectionGroupNumberInput extends MenuSectionGroupItem
{
	MenuSectionGroupNumberInput (String label, Function onChange, { num base, num min, num max, num step })
	{
		NumberInput numberInput = new NumberInput(base: base, min: min, max: max, step: step, units: 'm');
		
		numberInput.on['change'].listen((Event event) =>
											   onChange(numberInput.value));
		
		this._node..children.add(new Element.html('<span>$label</span>'))
				  ..children.add(numberInput.node);
	}
}