<?php
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

