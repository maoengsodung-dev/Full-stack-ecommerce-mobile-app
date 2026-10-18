<?php return array (
  'App\\Providers\\EventServiceProvider' => 
  array (
    'App\\Events\\OrderStatusChanged' => 
    array (
      0 => 
      array (
        0 => 'App\\Listeners\\SendOrderStatusNotification',
        1 => 'handleOrderStatusChanged',
      ),
    ),
    'App\\Events\\OrderShipped' => 
    array (
      0 => 
      array (
        0 => 'App\\Listeners\\SendOrderStatusNotification',
        1 => 'handleOrderShipped',
      ),
    ),
    'App\\Events\\PaymentConfirmed' => 
    array (
      0 => 'App\\Listeners\\SendPaymentConfirmedNotification',
    ),
    'App\\Events\\NewPromotion' => 
    array (
      0 => 'App\\Listeners\\BroadcastNewPromotion',
    ),
  ),
  'Illuminate\\Foundation\\Support\\Providers\\EventServiceProvider' => 
  array (
    'App\\Events\\NewPromotion' => 
    array (
      0 => 'App\\Listeners\\BroadcastNewPromotion@handle',
    ),
    'App\\Events\\OrderStatusChanged' => 
    array (
      0 => 'App\\Listeners\\SendOrderStatusNotification@handleOrderStatusChanged',
    ),
    'App\\Events\\OrderShipped' => 
    array (
      0 => 'App\\Listeners\\SendOrderStatusNotification@handleOrderShipped',
    ),
    'App\\Events\\PaymentConfirmed' => 
    array (
      0 => 'App\\Listeners\\SendPaymentConfirmedNotification@handle',
    ),
  ),
);