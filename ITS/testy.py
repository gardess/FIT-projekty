# -*- coding: utf-8 -*-

# Autor: Milan Gardáš
# Login: xgarda04

from selenium import webdriver
from selenium.webdriver.common.by import By
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import NoSuchElementException
from selenium.common.exceptions import NoAlertPresentException
import unittest, time, re

COMMAND_EXECUTOR = 'http://pcsmrcka.fit.vutbr.cz:4444/wd/hub'

class Pok(unittest.TestCase):
    def setUp(self):
        self.driver = webdriver.Remote(
                command_executor=COMMAND_EXECUTOR,
                desired_capabilities=webdriver.common.desired_capabilities.DesiredCapabilities.FIREFOX
                )
        self.driver.set_window_size(1280,800)
        self.base_url = "http://pcsmrcka.fit.vutbr.cz:8123/"
        self.verificationErrors = []
        self.accept_next_alert = True
    
    def test_10(self): # Nainstalování a aktivace pluginu
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='menu-plugins']/a/div[3]").click()
        driver.find_element_by_xpath("(//a[contains(text(),'Add New')])[4]").click()
        driver.find_element_by_name("s").clear()
        driver.find_element_by_name("s").send_keys("simple membership")
        driver.find_element_by_id("search-submit").click()
        driver.find_element_by_xpath("//div/div/div/div[2]/ul/li/a").click()
        driver.find_element_by_link_text("Activate Plugin").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
        
    def test_11(self): # Vytvoření skupin uživatelů a samotných uživatelů
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='toplevel_page_simple_wp_membership']/a/div[3]").click()
        driver.find_element_by_link_text("Membership Levels").click()
        driver.find_element_by_css_selector("a.button-primary").click()
        driver.find_element_by_id("alias").clear()
        driver.find_element_by_id("alias").send_keys("Gold")
        driver.find_element_by_id("createswpmlevelsub").click()
        driver.find_element_by_css_selector("a.button-primary").click()
        driver.find_element_by_id("alias").clear()
        driver.find_element_by_id("alias").send_keys("Silver")
        driver.find_element_by_id("createswpmlevelsub").click()
        driver.find_element_by_link_text("Members").click()
        driver.find_element_by_css_selector("a.button-primary").click()
        driver.find_element_by_id("user_name").clear()
        driver.find_element_by_id("user_name").send_keys("SilverUser")
        driver.find_element_by_id("email").clear()
        driver.find_element_by_id("email").send_keys("SilverUser@SilverUser.com")
        driver.find_element_by_id("pass1").clear()
        driver.find_element_by_id("pass1").send_keys("SilverUser")
        driver.find_element_by_id("pass2").clear()
        driver.find_element_by_id("pass2").send_keys("SilverUser")
        Select(driver.find_element_by_id("membership_level")).select_by_visible_text("Silver")
        driver.find_element_by_id("createswpmusersub").click()
        driver.find_element_by_css_selector("a.button-primary").click()
        driver.find_element_by_id("user_name").clear()
        driver.find_element_by_id("user_name").send_keys("GoldUser")
        driver.find_element_by_id("email").clear()
        driver.find_element_by_id("email").send_keys("GoldUser@GoldUser.com")
        driver.find_element_by_id("pass1").clear()
        driver.find_element_by_id("pass1").send_keys("GoldUser")
        driver.find_element_by_id("pass2").clear()
        driver.find_element_by_id("pass2").send_keys("GoldUser")
        driver.find_element_by_id("createswpmusersub").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
        
    def test_12(self): # Vytvoření článků pro testování
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='menu-posts']/a/div[3]").click()
        driver.find_element_by_link_text("Add New").click()
        driver.find_element_by_id("title-prompt-text").click()
        driver.find_element_by_id("title").clear()
        driver.find_element_by_id("title").send_keys("Only for Gold users")
        driver.find_element_by_id("content-html").click()
        driver.find_element_by_id("content").clear()
        driver.find_element_by_id("content").send_keys(u"Vidí pouze uživatelé z Gold skupiny")
        driver.find_element_by_xpath("(//input[@name='swpm_protect_post'])[2]").click()
        driver.find_element_by_xpath("//div[@id='swpm_sectionid']/div[2]/input[4]").click()
        driver.find_element_by_id("publish").click()
        driver.find_element_by_link_text("Add New").click()
        driver.find_element_by_id("title-prompt-text").click()
        driver.find_element_by_id("title").clear()
        driver.find_element_by_id("title").send_keys("Only for Silver users")
        driver.find_element_by_id("content-html").click()
        driver.find_element_by_id("content").clear()
        driver.find_element_by_id("content").send_keys(u"Vidí pouze uživatelé ze Silver skupiny")
        driver.find_element_by_xpath("(//input[@name='swpm_protect_post'])[2]").click()
        driver.find_element_by_xpath("//div[@id='swpm_sectionid']/div[2]/input[5]").click()
        driver.find_element_by_id("publish").click()
        driver.find_element_by_link_text("Add New").click()
        driver.find_element_by_id("title-prompt-text").click()
        driver.find_element_by_id("title").clear()
        driver.find_element_by_id("title").send_keys("Gold + Silver")
        driver.find_element_by_id("content-html").click()
        driver.find_element_by_id("content").clear()
        driver.find_element_by_id("content").send_keys(u"Vidí pouze uživaté ze skupiny Gold nebo Silver")
        driver.find_element_by_xpath("(//input[@name='swpm_protect_post'])[2]").click()
        driver.find_element_by_xpath("//div[@id='swpm_sectionid']/div[2]/input[4]").click()
        driver.find_element_by_xpath("//div[@id='swpm_sectionid']/div[2]/input[5]").click()
        driver.find_element_by_id("publish").click()
        driver.find_element_by_link_text("Add New").click()
        driver.find_element_by_id("title-prompt-text").click()
        driver.find_element_by_id("title").clear()
        driver.find_element_by_id("title").send_keys(u"Vidí všichni")
        driver.find_element_by_id("content-html").click()
        driver.find_element_by_id("content").click()
        driver.find_element_by_id("content").clear()
        driver.find_element_by_id("content").send_keys(u"Tento příspěvek vidí všichni")
        driver.find_element_by_name("swpm_protect_post").click()
        driver.find_element_by_id("publish").click()
        driver.find_element_by_link_text("Add New").click()
        driver.find_element_by_id("title-prompt-text").click()
        driver.find_element_by_id("title").clear()
        driver.find_element_by_id("title").send_keys(u"Nikdo nevidí")
        driver.find_element_by_id("content-html").click()
        driver.find_element_by_id("content").clear()
        driver.find_element_by_id("content").send_keys(u"Tento příspěvek nevidí nikdo")
        driver.find_element_by_xpath("(//input[@name='swpm_protect_post'])[2]").click()
        driver.find_element_by_id("publish").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
# ----------------------------------------------------------------------

    def test_13(self): # testuje co vše vidí nepřihlášený uživatel, má vidět pouze příspěvek "Vidí všichni"
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
        driver.find_element_by_css_selector("h2.entry-title > a").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text(u"Vidí všichni").click()
        self.assertEqual(u"Tento příspěvek vidí všichni", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Gold + Silver").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text("Only for Silver users").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text("Only for Gold users").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")

    def test_14(self): # testuje co vše vidí GoldUser, má vidět příspěvek "Vidí všichni", "Gold + Silver", "Only for Gold Users"
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("GoldUser")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("GoldUser")
        driver.find_element_by_id("wp-submit").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        self.assertEqual("Howdy, GoldUser", driver.find_element_by_link_text("Howdy, GoldUser").text)
        driver.find_element_by_css_selector("h2.entry-title > a").click()
        self.assertEqual("This content is not permitted for your membership level.", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text(u"Vidí všichni").click()
        self.assertEqual(u"Tento příspěvek vidí všichni", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Gold + Silver").click()
        self.assertEqual(u"Vidí pouze uživaté ze skupiny Gold nebo Silver", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Only for Silver users").click()
        self.assertEqual("This content is not permitted for your membership level.", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Only for Gold users").click()
        self.assertEqual(u"Vidí pouze uživatelé z Gold skupiny", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)

    def test_15(self): # testuje co vše vidí SilverUser, má vidět příspěvek "Vidí všichni", "Gold + Silver", "Only for Silver Users"
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("SilverUser")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("SilverUser")
        driver.find_element_by_id("wp-submit").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        self.assertEqual("Howdy, SilverUser", driver.find_element_by_link_text("Howdy, SilverUser").text)
        driver.find_element_by_css_selector("h2.entry-title > a").click()
        self.assertEqual("This content is not permitted for your membership level.", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text(u"Vidí všichni").click()
        self.assertEqual(u"Tento příspěvek vidí všichni", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Gold + Silver").click()
        self.assertEqual(u"Vidí pouze uživaté ze skupiny Gold nebo Silver", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Only for Silver users").click()
        self.assertEqual(u"Vidí pouze uživatelé ze Silver skupiny", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Only for Gold users").click()
        self.assertEqual("This content is not permitted for your membership level.", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)

    def test_16(self): # testuje co vše vidí admin, má vidět pouze příspěvek "Vidí všichni"
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_link_text(u"Nikdo nevidí").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text(u"Vidí všichni").click()
        self.assertEqual(u"Tento příspěvek vidí všichni", driver.find_element_by_css_selector("div.entry-content").text)
        driver.find_element_by_link_text("Gold + Silver").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text("Only for Silver users").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text("Only for Gold users").click()
        self.assertRegexpMatches(driver.find_element_by_css_selector("div.entry-content").text, r"^You need to login to view this content\. Please Login\. Not a Member[\s\S] Join Us$")
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)

# ----------------------------------------------------------------------


    def test_17(self): # Smazání článků pro testy
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='menu-posts']/a/div[3]").click()
        driver.find_element_by_id("cb-select-all-1").click()
        driver.find_element_by_id("cb-select-1").click()
        Select(driver.find_element_by_id("bulk-action-selector-top")).select_by_visible_text("Move to Trash")
        driver.find_element_by_id("doaction").click()
        driver.find_element_by_link_text("Trash (5)").click()
        driver.find_element_by_id("cb-select-all-1").click()
        Select(driver.find_element_by_id("bulk-action-selector-top")).select_by_visible_text("Delete Permanently")
        driver.find_element_by_id("doaction").click()
        self.assertEqual("No posts found in Trash.", driver.find_element_by_css_selector("td.colspanchange").text)
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)

    def test_18(self): # Vymaže vytvořené uživatele
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='toplevel_page_simple_wp_membership']/a/div[3]").click()
        driver.find_element_by_name("members[]").click()
        driver.find_element_by_xpath("(//input[@name='members[]'])[2]").click()
        Select(driver.find_element_by_id("bulk-action-selector-top")).select_by_visible_text("Delete")
        driver.find_element_by_id("doaction").click()
        self.assertEqual("No Member found.", driver.find_element_by_css_selector("td.colspanchange").text)
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)

    def test_19(self): # Vymaže vytvořené skupiny
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='toplevel_page_simple_wp_membership']/a/div[3]").click()
        driver.find_element_by_link_text("Membership Levels").click()
        driver.find_element_by_name("ids[]").click()
        driver.find_element_by_link_text("Delete").click()
        self.assertRegexpMatches(self.close_alert_and_get_its_text(), r"^Are you sure you want to delete this entry[\s\S]$")
        driver.find_element_by_name("ids[]").click()
        driver.find_element_by_link_text("Delete").click()
        self.assertRegexpMatches(self.close_alert_and_get_its_text(), r"^Are you sure you want to delete this entry[\s\S]$")
        self.assertEqual("No membership levels found.", driver.find_element_by_css_selector("td.colspanchange").text)
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
    
    def test_20(self): # Deaktivace a smazání pluginu
        driver = self.driver
        driver.get(self.base_url + "/xgarda04/")
        driver.find_element_by_link_text("Log in").click()
        driver.find_element_by_id("user_login").clear()
        driver.find_element_by_id("user_login").send_keys("xgarda04")
        driver.find_element_by_id("user_pass").clear()
        driver.find_element_by_id("user_pass").send_keys("fski")
        driver.find_element_by_id("wp-submit").click()
        self.assertEqual("Welcome to WordPress!", driver.find_element_by_css_selector("h3").text)
        self.assertEqual("Howdy, xgarda04", driver.find_element_by_link_text("Howdy, xgarda04").text)
        driver.find_element_by_xpath("//li[@id='menu-plugins']/a/div[3]").click()
        driver.find_element_by_link_text("Deactivate").click()
        driver.find_element_by_css_selector("#simple-wordpress-membership > td.plugin-title > div.row-actions.visible > span.delete > a.delete").click()
        driver.find_element_by_id("submit").click()
        driver.find_element_by_link_text("Wordpress xgarda04").click()
        driver.find_element_by_link_text("Log out").click()
        driver.find_element_by_css_selector("a[title=\"Are you lost?\"]").click()
        self.assertEqual("Log in", driver.find_element_by_link_text("Log in").text)
    
    def is_element_present(self, how, what):
        try: self.driver.find_element(by=how, value=what)
        except NoSuchElementException, e: return False
        return True
    
    def is_alert_present(self):
        try: self.driver.switch_to_alert()
        except NoAlertPresentException, e: return False
        return True
    
    def close_alert_and_get_its_text(self):
        try:
            alert = self.driver.switch_to_alert()
            alert_text = alert.text
            if self.accept_next_alert:
                alert.accept()
            else:
                alert.dismiss()
            return alert_text
        finally: self.accept_next_alert = True
    
    def tearDown(self):
        self.driver.quit()
        self.assertEqual([], self.verificationErrors)

if __name__ == "__main__":
    unittest.main()
