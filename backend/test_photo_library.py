import hashlib
import unittest
from pathlib import Path

from photo_library import attach_photo, entries, match_photo


class PhotoLibraryTests(unittest.TestCase):
    def test_catalog_files_and_attributions(self):
        photos = entries()
        self.assertEqual(len(photos), 30)
        self.assertEqual(len({p['id'] for p in photos}), 30)
        root = Path(__file__).resolve().parents[1]
        for photo in photos:
            with self.subTest(photo=photo['id']):
                self.assertTrue(photo['reviewed'])
                self.assertTrue(photo['author'])
                self.assertTrue(photo['licenseUrl'].startswith('https://'))
                self.assertTrue(photo['sourcePage'].startswith('https://commons.wikimedia.org/'))
                web = root / 'web-demo/ui-preview/assets' / photo['file']
                native = root / 'harmonyos/VegiSmart/entry/src/main/resources/rawfile' / photo['file']
                self.assertEqual(hashlib.sha256(web.read_bytes()).hexdigest(), photo['sha256'])
                self.assertEqual(web.read_bytes(), native.read_bytes())

    def test_requires_dish_name_ingredients_and_method(self):
        for photo in entries():
            names = [group[0] for group in photo['ingredientGroups']]
            with self.subTest(photo=photo['id']):
                self.assertEqual(match_photo(photo['name'], names, photo['methods'][0])['id'], photo['id'])
                self.assertIsNone(match_photo(photo['name'], [], photo['methods'][0]))
                self.assertIsNone(match_photo(photo['name'], names, '未知做法'))
        self.assertIsNone(match_photo('香菇上海青', ['上海青', '香菇'], '焖烧'))
        self.assertIsNone(match_photo('番茄豆腐汤', ['番茄', '豆腐'], '煮汤'))

    def test_api_photo_payload_keeps_credit(self):
        recipe = dict(name='西红柿炒鸡蛋', method='快炒', image='recipe-placeholder.svg',
                      items=[{'name': '西红柿'}, {'name': '鸡蛋'}])
        attach_photo(recipe)
        self.assertEqual(recipe['image'], 'library/tomato-egg.jpg')
        self.assertEqual(recipe['photoCredit']['license'], 'CC BY-SA 3.0')
        self.assertIn('sourcePage', recipe['photoCredit'])


if __name__ == '__main__':
    unittest.main()
