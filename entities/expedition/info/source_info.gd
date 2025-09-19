class_name SourceInfo
extends PanelContainer


@export var expedition: Expedition

var source: Source:
	set(value_):
		source = value_
		visible = source != null
		
		%Terrain.text = source.resource.biome.terrain
		%Element.text = source.resource.element
