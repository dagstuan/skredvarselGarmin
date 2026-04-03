import Toybox.Lang;

using Toybox.WatchUi as Ui;
using Toybox.Graphics as Gfx;
using Toybox.Activity;

class DatafieldRootView extends Ui.DataField {
  private var _forecastView as DatafieldForecastView? = null;
  private var _subscriptionView as DatafieldSubscriptionView? = null;
  private var _showSubscription as Boolean = false;
  private var _forecastNeedsLayout as Boolean = true;

  public function initialize(showSubscription as Boolean) {
    DataField.initialize();
    _showSubscription = showSubscription;
  }

  public function onDataChanged() as Void {
    if (_showSubscription) {
      if (_subscriptionView != null) {
        (_subscriptionView as DatafieldSubscriptionView).onDataChanged();
      }
      return;
    }

    if (_forecastView != null) {
      (_forecastView as DatafieldForecastView).onDataChanged();
    }
  }

  public function showSubscriptionView() as Void {
    if (_showSubscription) {
      return;
    }

    _showSubscription = true;
    _subscriptionView = new DatafieldSubscriptionView();
    (_subscriptionView as DatafieldSubscriptionView).onShow();
    Ui.requestUpdate();
  }

  public function showForecastView() as Void {
    if (_subscriptionView != null) {
      (_subscriptionView as DatafieldSubscriptionView).onHide();
    }

    _showSubscription = false;
    _ensureForecastView();
    _forecastNeedsLayout = true;
    (_forecastView as DatafieldForecastView).onDataChanged();
    Ui.requestUpdate();
  }

  public function onLayout(dc as Gfx.Dc) as Void {
    if (_showSubscription) {
      _ensureSubscriptionView();
      (_subscriptionView as DatafieldSubscriptionView).onShow();
      return;
    }

    _ensureForecastView();
    (_forecastView as DatafieldForecastView).onLayout(dc);
    _forecastNeedsLayout = false;
  }

  public function compute(info as Activity.Info) as Void {
    if (_showSubscription) {
      _ensureSubscriptionView();
      (_subscriptionView as DatafieldSubscriptionView).compute();
      return;
    }

    _ensureForecastView();
    (_forecastView as DatafieldForecastView).compute(info);
  }

  public function onUpdate(dc as Gfx.Dc) as Void {
    if (_showSubscription) {
      _ensureSubscriptionView();
      (_subscriptionView as DatafieldSubscriptionView).onShow();
      (_subscriptionView as DatafieldSubscriptionView).onUpdate(dc);
      return;
    }

    _ensureForecastView();
    if (_forecastNeedsLayout) {
      (_forecastView as DatafieldForecastView).onLayout(dc);
      _forecastNeedsLayout = false;
    }
    (_forecastView as DatafieldForecastView).onUpdate(dc);
  }

  private function _ensureForecastView() as Void {
    if (_forecastView == null) {
      _forecastView = new DatafieldForecastView();
      _forecastNeedsLayout = true;
    }
  }

  private function _ensureSubscriptionView() as Void {
    if (_subscriptionView == null) {
      _subscriptionView = new DatafieldSubscriptionView();
    }
  }
}
