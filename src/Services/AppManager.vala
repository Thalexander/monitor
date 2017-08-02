namespace elementarySystemMonitor {

    public struct App {
        public string name;
        public string icon;
        public int[] pids;
    }
	/**
	 * Wrapper for Bamf.Matcher
	 */
	public class AppManager {

		// public signal void active_window_changed (Bamf.Window? old_win, Bamf.Window? new_win);
		// public signal void window_opened (Bamf.Window w);
		// public signal void window_closed (Bamf.Window w);
        //
		// public signal void active_application_changed (Bamf.Application? old_app, Bamf.Application? new_app);
		public signal void application_opened (App app);
		// public signal void application_closed (Bamf.Application app);

		static AppManager? app_manager = null;
        Bamf.Matcher? matcher;

		public static AppManager get_default ()
		{
			if (app_manager == null)
				app_manager = new AppManager ();
			return app_manager;
		}


		public AppManager () {
			matcher = Bamf.Matcher.get_default ();
			// matcher.active_application_changed.connect_after (handle_active_application_changed);
			// matcher.active_window_changed.connect_after (handle_active_window_changed);
            matcher.view_opened.connect (handle_view_opened);
			// matcher.view_closed.connect_after (handle_view_closed);
            //
			// pending_views = new Gee.HashSet<Bamf.View> ();
		}


		// ~AppManager () {
			// foreach (var view in pending_views)
			// 	view.user_visible_changed.disconnect (handle_view_user_visible_changed);
            //
			// matcher.active_application_changed.disconnect (handle_active_application_changed);
			// matcher.active_window_changed.disconnect (handle_active_window_changed);
			// matcher.view_opened.disconnect (handle_view_opened);
			// matcher.view_closed.disconnect (handle_view_closed);
			// matcher = null;
		// }

        // Function retrieves a Bamf.view, checks if it's an app or a window,
        // then extracts name, icon and pid. After that, sends signal.
        // Why so complicated ? Some apps opened thru Slingshot aren't
        // recognized as apps, but windows.

		void handle_view_opened (Bamf.View view) {
            int[] win_pids = {};
            if (view is Bamf.Application) {
                debug ("***handle_view_opened: is an app: %s", view.get_name());

                var app = (Bamf.Application)view;
                // go through the windows of the application and add all of the pids
                var windows = app.get_windows ();
                foreach (var window in windows) {
                    win_pids += (int)window.get_pid ();
                }
                application_opened (
                    App () {
                        name = app.get_name (),
                        icon = app.get_icon (),
                        pids = win_pids
                    }
                );
            }
            if (view is Bamf.Window) {
                debug ("***handle_view_opened: is a win: %s", view.get_name());
                var window = (Bamf.Window)view;
                win_pids += (int)window.get_pid();
                application_opened (
                    App () {
                        name = window.get_name (),
                        icon = window.get_icon (),
                        pids = win_pids
                    }
                );
            }
		}

		void handle_view_closed (Bamf.View arg1) {

        }

	}
}
