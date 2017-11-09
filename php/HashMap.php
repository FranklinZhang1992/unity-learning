<?php

Class HashMap{
 var $H_table;
  /*
   * HashMap构造函数
   */
  public function __construct() {
   $this->H_table = array ();
  }
  /*
   *向HashMap中添加一个键值对
   *@param $key 插入的键
   *@param $value 插入的值
  */
 public function put($key, $value) {
  if (!array_key_exists($key, $this->H_table)) {
     $this->H_table[$key] = $value;
     return null;
  } else {
     $tempValue = $this->H_table[$key];
     $this->H_table[$key] = $value;
     return $tempValue;
  }
  }
  
  /*
  * 根据key获取对应的value
  * @param $key
  */
  public function get($key) {
   if (array_key_exists($key, $this->H_table))
    return $this->H_table[$key];
   else
    return null;
  }
  /*
   *移除HashMap中所有键值对
  */
  /*
   *删除指定key的键值对
   *@param $key 要移除键值对的key
   */
  public function remove($key) {
   $temp_table = array ();
   if (array_key_exists($key, $this->H_table)) {
    $tempValue = $this->H_table[$key];
    while ($curValue = current($this->H_table)) {
     if (!(key($this->H_table) == $key))
      $temp_table[key($this->H_table)] = $curValue;
 
     next($this->H_table);
    }
    $this->H_table = null;
    $this->H_table = $temp_table;
    return $tempValue;
   } else
    return null;
  }
  
  /**
   * 获取HashMap的所有键值
   * @return 返回HashMap中key的集合,以数组形式返回
   */
  public function keys(){
   return array_keys($this->H_table);
  }
  /**
   * 获取HashMap的所有value值
   */
  public function values(){
   return array_values($this->H_table);
  }
  
  /**
   * 将一个HashMap的值全部put到当前HashMap中
   * @param $map
   */
  public function putAll($map){
   if(!$map->isEmpty()&& $map->size()>0){
    $keys = $map->keys();
    foreach($keys as $key){
     $this->put($key,$map->get($key));
    }
   }
  }
  
  /**
   * 移除HashMap中所有元素
   */
  public function removeAll() {
   $this->H_table = null;
   $this->H_table = array ();
  }
  /*
   *HashMap中是否包含指定的值
   *@param $value
  */
  public function containsValue($value) {
    while ($curValue = current($this->H_table)) {
     if ($curValue == $value) {
      return true;
     }
     next($this->H_table);
    }
    return false;
  }
  /*
   *HashMap中是否包含指定的键key
   *@param $key
  */
  public function containsKey($key) {
    if (array_key_exists($key, $this->H_table)) {
     return true;
    } else {
     return false;
    }
  }
  /*
   *获取HashMap中元素个数
   */
  public function size() {
   return count($this->H_table);
  }
 
  
  /*
  *判断HashMap是否为空
  */
  public function isEmpty() {
   return (count($this->H_table) == 0);
  }
  /**
   * 
   */
  public function toString() {
   print_r($this->H_table);
  }
}

class ObjBase
{

    public $name;

}

class Area extends ObjBase
{
    public $cities = [];

    public function __construct($name, $city) {
       $this->name = $name;
       $this->cities = $city;
    }

    public function push($city){
      $cities[] = $city;
    }
}


class City extends ObjBase
{
    public $stores = [];
    public $area;

    public function __construct($name, $store, $area) {
       $this->name = $name;
       $this->stores = $store;
       $this->area = $area;
    }

    public function push($store){
      $stores[] = $store;
    }
}

class Answer
{
  public $area;
  public $city;
  public $store;

  public function __construct($area, $city, $store) {
       $this->area = $area;
       $this->store = $store;
       $this->city = $city;
    }
}


function mockup()
{
  $answers = [];
  $answer = new Answer("华东大区", "上海", "莲花");
  $answers[] = $answer;
  $answer = new Answer("华东大区", "上海", "石库门");
  $answers[] = $answer;
  $answer = new Answer("华中大区", "北京", "京东");
  $answers[] = $answer;
  $answer = new Answer("华中大区", "天津", "广玉兰");
  $answers[] = $answer;
  $answer = new Answer("华南大区", "深圳", "天猫");
  $answers[] = $answer;
  $answer = new Answer("港澳大区", "香港", "迪士尼");
  $answers[] = $answer;
  return $answers;
}

$answers = mockup();

//var_dump($answers);

$cityHash = new HashMap();
foreach ($answers  as $answer) {
  $cityName = $answer->city;
  if ($cityHash->containsKey($cityName)){
    $cityHash->get($cityName)->push($answer->store);
  } else {
    $cityHash->put($cityName , new City($cityName, $answer->store, $answer->area));
  }
}

//var_dump($cityHash->values());

$areaHash = new HashMap();
foreach ($cityHash->values() as $city) {
  $areaName = $city->area;
  if ($areaHash->containsKey($areaName)){
    $areaHash->get($areaName)->push($city);
  } else {
    $areaHash->put($areaName , new Area($areaName, $city));
  }
}

var_dump($areaHash);


/*
    $map = new HashMap();
    $map->put("shanghai", "zhangjiang");
    $map->put("shanghai", "nnajingroad");
    $map->put("shanghai", "park");
    $map->put("beijing", "xidan");

    //var_dump($map->keys());
    //var_dump($map->values());
    //var_dump($map->get('shanghai'));

    $answer = new Answer("华东大区", "上海", "莲花");
    //var_dump($answer);
    $answers = $answer;
    var_dump($answers);
*/

?>
