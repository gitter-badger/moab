[%%shared
	open Eliom_lib
	open Eliom_content
	open Html.D
	open Eliom_service
	open Eliom_parameter
]

[%%server
	open Services
	open Moab
	open CalendarLib
]

let do_generate_report () (from_week, to_week) =
	let (tmpnam, out_ch) = Filename.open_temp_file "moab_report" ".csv" in
	let csv_ch = Csv.to_channel out_ch in
	Lwt.catch (fun () -> 
		let%lwt students = Moab_db.get_students ~active_only:false !Moab.term in
		let%lwt planned = Lwt_list.map_s (fun (id, _, _) -> Moab_db.get_planned_sessions id !Moab.term) students in
		let%lwt csv = Lwt_list.mapi_s (fun n (year, week, sessions) ->
			match year, week, sessions with
			| Some y, Some w, Some s -> 
					let wk = Int32.to_int w in
					let lw = n + 1 in
					if (lw >= from_week) && (lw <= to_week) then
						let (sw, _) = Date.week_first_last wk y in
						let%lwt	users = Moab_db.get_user_attendance !Moab.term lw in 	
						Lwt_list.map_s (fun (uid, fn, ln, p, x, vs) ->
							let student_id = Moab_utils.default "" p in
							let nr_sessions = Moab_utils.default 0L x in
							Lwt.return [string_of_int lw;
							Int64.to_string s;
							student_id;
							Int64.to_string nr_sessions;
							Printer.Date.sprint "%Y-%m-%d" sw;
							"";
							uid;
							fn;
							ln;
							(Printf.sprintf "%s@live.mdx.ac.uk" uid);
							(match vs with | Some true -> "1" | _ -> "0");
							""	
							]	
						) users
					else
						Lwt.return []
			| _, _, _ -> Lwt.return []
		) (List.flatten planned) in
		let csv_header = ["Week number"; "Scheduled sessions"; "Student Number"; "Sessions attended"; "Week starting"; "Tutor"; "Network Name"; "First Name"; "Last Name"; "Email"; "Visa?"; "Foundation?"] in
			Csv.output_all csv_ch (csv_header::
				List.sort (fun [_; _; _; _; _; _; x; _; _; _; _; _] [_; _; _; _; _; _; y; _; _; _; _; _] -> compare x y) (List.flatten csv));
			Csv.close_out csv_ch;
			Eliom_registration.File.send ~content_type:"text/csv" tmpnam
	)
	(function
	| e -> error_page (Printexc.to_string e)
	)
;;

let attendance_report_page () () =
	let generate_report_service = create ~path:(Path ["attendance_report.csv"])
		~meth:(Post (unit, int "from_week" ** int "to_week")) () in
	Eliom_registration.Any.register ~scope:Eliom_common.default_session_scope
		~service:generate_report_service do_generate_report;
	let%lwt u = Eliom_reference.get user in
	match u with
	| None -> Eliom_registration.Redirection.send (Eliom_registration.Redirection login_service)
	| Some (uid, _, _, _) -> 
		Lwt.catch (fun () ->
			let%lwt x = Moab_db.last_learning_week 1 !Moab.term in
			let llw = match x with
			| None -> 25
			| Some y -> y in
			let fw = max 1 (llw - 5) in
			let tw = max 1 (llw - 1) in
			container [
				h1 [pcdata "Weekly attendance report"];
				Form.post_form ~service:generate_report_service 
				(fun (from_week, to_week) -> [
					table
					[
						tr [
							th [pcdata "From learning week: "];
							td [Form.input ~input_type:`Text ~name:from_week ~value:fw Form.int]
						];
						tr [
							th [pcdata "To learning week: "];
							td [Form.input ~input_type:`Text ~name:to_week ~value:tw Form.int]
						];
						tr [
							td ~a:[a_colspan 2] [Form.input ~input_type:`Submit ~value:"Generate" Form.string]
						]
					]
				]) ()
			]
		)
		(function
		| e -> error_page (Printexc.to_string e))
;;

let () =
  Eliom_registration.Any.register ~service:attendance_report_service attendance_report_page;
;;
