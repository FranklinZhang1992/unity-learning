<?php
use HashMap;

class ObjBase
{

    public $name;

}

class Area extends ObjBase
{
    public $cities[];

    public function __construct($name, $city) {
       $name = $name;
       $cities[] = $city;
    }
}


class City extends ObjBase
{
    public $stores[];
    public $area;

    public function __construct($name, $store, $area) {
       $name = $name;
       $stores[] = $store;
       $area = $area;
    }
}

