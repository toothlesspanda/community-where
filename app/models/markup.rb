class Markup < ApplicationRecord
  set_rgeo_factory_for_column(:coordinates, RGeo::Geographic.spherical_factory(srid: 4326))
end
