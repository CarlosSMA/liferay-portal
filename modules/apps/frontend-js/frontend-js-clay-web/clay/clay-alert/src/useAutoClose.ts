/**
 * SPDX-FileCopyrightText: (c) 2026 Liferay, Inc. https://liferay.com
 * SPDX-License-Identifier: LGPL-2.1-or-later OR LicenseRef-Liferay-DXP-EULA-2.0.0-2023-06
 */

import React from 'react';

export function useAutoClose(autoClose?: boolean | number, onClose = () => {}) {
	const startedTimeRef = React.useRef<number>(0);
	const timerRef = React.useRef<number | undefined>(undefined);
	const timeToCloseRef = React.useRef(autoClose === true ? 10000 : autoClose);
	let pauseTimer = () => {};
	let startTimer = () => {};
	if (autoClose) {
		pauseTimer = () => {
			if (timerRef.current) {
				timeToCloseRef.current =
					(timeToCloseRef.current as number) -
					(Date.now() - startedTimeRef.current);
				clearTimeout(timerRef.current);
				timerRef.current = undefined;
			}
		};
		startTimer = () => {
			startedTimeRef.current = Date.now();
			timerRef.current = window.setTimeout(
				onClose,
				timeToCloseRef.current as number
			);
		};
	}
	React.useEffect(() => {
		if (autoClose) {
			startTimer();

			return pauseTimer;
		}
	}, []);

	return {
		pauseAutoCloseTimer: pauseTimer,
		startAutoCloseTimer: startTimer,
	};
}
